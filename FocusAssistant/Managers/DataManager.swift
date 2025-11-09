//
//  SignInVM.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Observation

@MainActor
@Observable
class DataManager {
    // MARK: - Authentication Properties
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    var isAuthenticated: Bool { if isTest { return true } else { return currentUser != nil } }
    var isTest: Bool = false
    
    // MARK: - Data Properties
    var tasks: [UserTask] = []
    var focusSessions: [FocusSession] = []
    var habits: [Habit] = []
    var reminders: [Reminder] = []
    var currentInsights: UserInsights?
    
    // MARK: - Data Repositories
    private var taskRepository: FirestoreRepository<UserTask>?
    private var habitRepository: FirestoreRepository<Habit>?
    private var reminderRepository: FirestoreRepository<Reminder>?
    
    // MARK: - UI State
    var loadingState: LoadingState = .idle
    var alertError: AlertError?
    
    // Computed property for easier alert binding
    var showingAlert: Bool {
        alertError != nil
    }
    
    // MARK: - Private Properties
    // Has to be functions due to environment object
    private func auth() -> Auth { Auth.auth() }
    private func db() -> Firestore { Firestore.firestore() }
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var listeners: [ListenerRegistration] = []
    
    private var userId: String {
        userSession?.uid ?? ""
    }
    
    // MARK: - Initialization
    init() {} // This is due to environment objects initialising before the App does, due to the way views work
    
    init(currentUser: User) {
        // This is only used in the previewer
        self.currentUser = currentUser
    }
    init(isTest: Bool) {
        self.isTest = isTest
        self.setPreview()
    }
    
    func start() {
        setupAuthStateListener()
        checkCurrentUser()
    }
    
    func checkCurrentUser() {
        self.userSession = auth().currentUser
        if userSession != nil {
            setupRepositories()
            
            Task {
                try await fetchUser()
                await loadAllData()
            }
        }
    }
    
    @MainActor
    deinit {
        if let listener = authStateListener {
            auth().removeStateDidChangeListener(listener)
        }
        listeners.forEach { $0.remove() }
    }
    
    // MARK: - Data Loading
    func loadAllData() async {
        guard isAuthenticated else { return }
        guard !isTest else { return }
        loadingState = .loading
        defer { loadingState = .idle }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await self.fetchTasks() }
            group.addTask { try await self.fetchFocusSessions() }
            group.addTask { try await self.fetchHabits() }
            group.addTask { try await self.fetchReminders() }
        }
    }
    
    private func setPreview() {
        guard self.isTest else { return }
        
        self.currentUser = User(
            id: "preview-user-123",
            fullName: "John Preview",
            email: "john.preview@example.com"
        )
        // Populate with dummy data
        self.tasks = PreviewData.sampleTasks
        self.focusSessions = PreviewData.sampleFocusSessions
        self.habits = PreviewData.sampleHabits
        self.reminders = PreviewData.sampleReminders
        self.currentInsights = PreviewData.sampleInsights
    }
}

// MARK: - Authentication Methods
@MainActor extension DataManager {
    func signIn(withEmail email: String, password: String) async throws {
        loadingState = .loading
        defer { loadingState = .idle }
        
        do {
            let result = try await auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await fetchUser()
            await loadAllData()
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .auth, action: .signIn))
            throw error
        }
    }
    
    func signUp(withEmail email: String, password: String, confirmPassword: String, fullName: String) async throws {
        loadingState = .loading
        guard password == confirmPassword else {
            alertError = .passwordMismatch
            throw DataManagerError.passwordMismatch
        }
        defer { loadingState = .idle }
        
        do {
            let result = try await auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            try usersCollection.document(user.id).setData(from: user)
            
            try await fetchUser()
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .auth, action: .signUp))
            throw error
        }
    }
    
    func signOut() {
        loadingState = .loading
        defer { loadingState = .idle }
        
        do {
            try auth().signOut()
            clearUserData()
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .auth, action: .signOut))
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth().sendPasswordReset(withEmail: email)
        } catch {
            alertError = .failed(.auth, .resetPassword)
            throw error
        }
    }
    
    func deleteAccount() async throws {
        guard let user = auth().currentUser else {
            throw NSError(domain: "DataManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        loadingState = .loading
        defer { loadingState = .idle }
        
        do {
            try await usersCollection.document(user.uid).delete()
            await deleteUserData(userId: user.uid)
            try await user.delete()
            clearUserData()
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .user, action: .delete))
            throw error
        }
    }
    
    func updateUserProfile(fullName: String) async throws {
        guard !userId.isEmpty else {
            throw DataManagerError.notAuthenticated
        }
        
        do {
            try await usersCollection.document(userId).updateData([
                "fullName": fullName
            ])
            currentUser?.fullName = fullName
        } catch {
            alertError = .failed(.user, .profileUpdate)
            throw error
        }
    }
    
    private func fetchUser() async throws {
        do {
            let snapshot = try await usersCollection.document(userId).getDocument()
            guard snapshot.exists else { return }
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .user, action: .fetch))
            throw error
        }
    }
    
    private func deleteUserData(userId: String) async {
        let collections = ["tasks", "focusSessions", "habits", "reminders", "dailyStats"]
        
        for collection in collections {
            do {
                let snapshot = try await db().collection("users")
                    .document(userId)
                    .collection(collection)
                    .getDocuments()
                
                for document in snapshot.documents {
                    try await document.reference.delete()
                }
            } catch {
                print("Failed to delete \(collection): \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Auth State Management
@MainActor extension DataManager {
    private func setupAuthStateListener() {
        authStateListener = auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.userSession = user
                if user != nil {
                    try await self?.fetchUser()
                    await self?.loadAllData()
                } else {
                    self?.clearUserData()
                }
            }
        }
    }
    
    private func clearUserData() {
        currentUser = nil
        tasks = []
        focusSessions = []
        habits = []
        reminders = []
        currentInsights = nil
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    
    // MARK: - Error Handling Helpers
    func clearAlertError() {
        alertError = nil
    }
}

// MARK: - Convenience Extensions
extension DataManager {
    var todaysTasks: [UserTask] {
        tasks.filter { task in
            if let dueDate = task.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            }
            if let scheduledDate = task.scheduledDate {
                return Calendar.current.isDateInToday(scheduledDate)
            }
            return false
        }
    }
    
    var completedTodaysTasks: [UserTask] {
        todaysTasks.filter { $0.isCompleted }
    }
    
    var overdueTasks: [UserTask] {
        tasks.filter { $0.isOverdue && $0.isCompleted == false}
    }
    
    var activeFocusSession: FocusSession? {
        focusSessions.first { $0.isActive }
    }
    
    var upcomingReminders: [Reminder] {
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        return reminders.filter { $0.triggerDate <= nextHour && $0.isCompleted == false}
    }
    
    var todaysHabits: [Habit] {
        habits.filter { $0.shouldShowToday }
    }
}

// MARK: - Task Management
extension DataManager {
    
    func createTask(_ task: UserTask) async throws {
        guard let repo = taskRepository else { throw DataManagerError.notAuthenticated }
        
        do {
            try await repo.create(task)
            try await fetchTasks()
        } catch {
            alertError = .failed(.task, .create)
            throw error
        }
    }
    
    func updateTask(_ task: UserTask) async throws {
        guard let repo = taskRepository else { throw DataManagerError.notAuthenticated }
        do {
            try await repo.update(task)
            try await fetchTasks()
        } catch {
            alertError = .failed(.task, .update)
            throw error
        }
    }
    
    func deleteTask(_ task: UserTask) async throws {
        guard let repo = taskRepository else { throw DataManagerError.notAuthenticated }
        do {
            try await repo.delete(task)
            try await fetchTasks()
        } catch {
            alertError = .failed(.task, .delete)
            throw error
        }
  
    }
    
    func fetchTasks() async throws {
        guard let repo = taskRepository else { return }
        do {
            tasks = try await repo.fetchAll { query in
                query.order(by: "createdAt", descending: true)
            }
        } catch {
            alertError = .failed(.task, .fetch)
            throw error
        }
    }
    
    func completeTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        do {
            var completedTask = task
            completedTask.isCompleted = true
            completedTask.completedAt = Date()
            completedTask.updatedAt = Date()
            try await updateTask(completedTask)
            try await updateDailyStats(completedTasks: 1)
        } catch {
            alertError = .failed(.task, .complete)
            throw error
        }
    }
    
    func uncompleteTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        guard task.isCompleted else { return }
        
        do {
            var completedTask = task
            completedTask.isCompleted = false
            completedTask.completedAt = nil
            completedTask.updatedAt = Date()
            try await updateTask(completedTask)
            try await updateDailyStats(completedTasks: -1)
        } catch {
            alertError = .failed(.task, .uncomplete)
            throw error
        }
    }
}

// MARK: - Focus Session Management
extension DataManager {
    func startFocusSession(_ session: FocusSession) async throws {
        guard isAuthenticated else { return }
        
        var activeSession = session
        activeSession.status = .active
        activeSession.startTime = Date()
        
        do {
            let encodedSession = try Firestore.Encoder().encode(activeSession)
            guard let id = session.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Session ID is missing"])
            }
            try await focusSessionsCollection.document(id).setData(encodedSession)
            try await fetchFocusSessions()
        } catch {
            alertError = .failed(.focusSession, .start)
            throw error
        }
    }
    
    func pauseFocusSession(_ session: FocusSession) async throws {
        guard isAuthenticated else { return }
        
        var pausedSession = session
        pausedSession.status = .paused
        pausedSession.pauseCount += 1
        pausedSession.updatedAt = Date()
        
        try await updateFocusSession(pausedSession)
    }
    
    func completeFocusSession(_ session: FocusSession, actualDuration: Int) async throws {
        guard isAuthenticated else { return }
        
        do {
            var completedSession = session
            completedSession.status = .completed
            completedSession.endTime = Date()
            completedSession.actualDuration = actualDuration
            completedSession.updatedAt = Date()
            
            try await updateFocusSession(completedSession)
            try await updateDailyStats(focusTime: actualDuration)
        } catch {
            alertError = .failed(.focusSession, .complete)
            throw error
        }
    }
    
    func updateFocusSession(_ session: FocusSession) async throws {
        guard isAuthenticated else { return }
        
        do {
            let encodedSession = try Firestore.Encoder().encode(session)
            guard let id = session.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Session ID is missing"])
            }
            try await focusSessionsCollection.document(id).setData(encodedSession, merge: true)
            try await fetchFocusSessions()
        } catch {
            alertError = .failed(.focusSession, .update)
            throw error
        }
    }
    
    func fetchFocusSessions() async throws {
        guard isAuthenticated else { return }
        
        do {
            let snapshot = try await focusSessionsCollection
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            self.focusSessions = snapshot.documents.compactMap { doc in
                try? doc.data(as: FocusSession.self)
            }
        } catch {
            alertError = .failed(.focusSession, .fetch)
            throw error
        }
    }
    
}

// MARK: - Habit Management
extension DataManager {
    func createHabit(_ habit: Habit) async throws {
        guard let repo = habitRepository else { throw DataManagerError.notAuthenticated }
        
        do {
            try await repo.create(habit)
            try await fetchHabits()
        } catch {
            alertError = .failed(.habit, .create)
            throw error
        }
    }
    
    func updateHabit(_ habit: Habit) async throws {
        guard let repo = habitRepository else { throw DataManagerError.notAuthenticated }
        do {
            try await repo.update(habit)
            try await fetchHabits()
        } catch {
            alertError = .failed(.habit, .update)
            throw error
        }
    }
    
    func deleteHabit(_ habit: Habit) async throws {
        guard let repo = habitRepository else { throw DataManagerError.notAuthenticated }
        do {
            try await repo.delete(habit)
            try await fetchHabits()
        } catch {
            alertError = .failed(.habit, .delete)
            throw error
        }
  
    }
    
    func fetchHabits() async throws {
        guard let repo = habitRepository else { return }
        do {
            habits = try await repo.fetchAll { query in
                query.order(by: "createdAt", descending: true)
            }
        } catch {
            alertError = .failed(.habit, .fetch)
            throw error
        }
    }
    
    func completeHabit(_ habit: Habit, completion: HabitCompletion) async throws {
        guard isAuthenticated else { return }
        
        do {
            let completionData = try Firestore.Encoder().encode(completion)
            try await db().collection("habitCompletions").document(completion.id).setData(completionData)
            
            var updatedHabit = habit
            updatedHabit.totalCompletions += 1
            updatedHabit.currentStreak += 1
            if updatedHabit.currentStreak > updatedHabit.longestStreak {
                updatedHabit.longestStreak = updatedHabit.currentStreak
            }
            updatedHabit.updatedAt = Date()
            
            try await updateHabit(updatedHabit)
            try await updateDailyStats(completedHabits: 1)
        } catch {
            alertError = .failed(.habit, .complete)
            throw error
        }
    }
}

// MARK: - Reminder Management
extension DataManager {
    func createReminder(_ reminder: Reminder) async throws {
        guard let repo = reminderRepository else { throw DataManagerError.notAuthenticated }
        
        do {
            try await repo.create(reminder)
            try await fetchReminders()
        } catch {
            alertError = .failed(.reminder, .create)
            throw error
        }
    }
    
    func updateReminder(_ reminder: Reminder) async throws {
        guard let repo = reminderRepository else { throw DataManagerError.notAuthenticated }
        
        do {
            try await repo.update(reminder)
            try await fetchReminders()
        } catch {
            alertError = .failed(.reminder, .update)
            throw error
        }
    }
    
    func fetchReminders() async throws {
        guard let repo = reminderRepository else { throw DataManagerError.notAuthenticated }
        
        do {
            reminders = try await repo.fetchAll { query in
                query.order(by: "createdAt", descending: true)
            }
        } catch {
            alertError = .failed(.reminder, .fetch)
            throw error
        }
    }
    
    func completeReminder(_ reminder: Reminder) async throws {
        guard reminderRepository != nil else { throw DataManagerError.notAuthenticated }
        
        do {
            var completedReminder = reminder
            completedReminder.isCompleted = true
            completedReminder.updatedAt = Date()
            
            try await updateReminder(completedReminder)
            try await fetchReminders()
        } catch {
            alertError = .failed(.reminder, .complete)
            throw error
        }
    }
    
    func snoozeReminder(_ reminder: Reminder, for minutes: Int) async throws {
        guard isAuthenticated else { return }
        
        do {
            var snoozedReminder = reminder
            snoozedReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date()) ?? Date()
            snoozedReminder.snoozeCount += 1
            snoozedReminder.lastSnoozedAt = Date()
            snoozedReminder.updatedAt = Date()
            
            try await updateReminder(snoozedReminder)
        } catch {
            alertError = .failed(.reminder, .snooze)
            throw error
        }
    }
}

// MARK: - Analytics and Insights
extension DataManager {
    func generateInsights(for dateRange: DateInterval) async throws -> UserInsights {
        guard isAuthenticated else {
            throw DataManagerError.notAuthenticated
        }
        
        var insights = UserInsights(dateRange: dateRange)
        
        let completedSessions = focusSessions.filter { $0.isCompleted }
        insights.totalFocusTime = completedSessions.compactMap { $0.actualDuration }.reduce(0, +)
        insights.averageSessionLength = completedSessions.isEmpty ? 0 :
        Double(insights.totalFocusTime) / Double(completedSessions.count)
        
        insights.completedTasks = tasks.filter { $0.isCompleted }.count
        insights.completedHabits = habits.reduce(0) { $0 + $1.totalCompletions }
        
        self.currentInsights = insights
        return insights
    }
    
    private func updateDailyStats(focusTime: Int = 0, completedTasks: Int = 0, completedHabits: Int = 0) async throws {
        guard isAuthenticated else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = ISO8601DateFormatter()
        let todayString = dateFormatter.string(from: today)
        
        do {
            let statsRef = dailyStatsCollection.document("\(userId)_\(todayString)")
            try await statsRef.setData([
                "date": today,
                "focusTime": FieldValue.increment(Int64(focusTime)),
                "completedTasks": FieldValue.increment(Int64(completedTasks)),
                "completedHabits": FieldValue.increment(Int64(completedHabits))
            ], merge: true)
        } catch {
            alertError = .failed(.stats, .update)
            throw error
        }
    }
}

// MARK: - Collection References
extension DataManager {
    private var usersCollection: CollectionReference {
        db().collection("users")
    }
    
    private var tasksCollection: CollectionReference {
        db().collection("users").document(userId).collection("tasks")
    }
    
    private var focusSessionsCollection: CollectionReference {
        db().collection("users").document(userId).collection("focusSessions")
    }
    
    private var habitsCollection: CollectionReference {
        db().collection("users").document(userId).collection("habits")
    }
    
    private var remindersCollection: CollectionReference {
        db().collection("users").document(userId).collection("reminders")
    }
    
    private var dailyStatsCollection: CollectionReference {
        db().collection("users").document(userId).collection("dailyStats")
    }
}

// MARK: - Real-time Listeners
extension DataManager {
    func startListeningToTasks() {
        guard isAuthenticated else { return }
        
        let listener = tasksCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let _ = error {
                    Task { @MainActor in
                        self.loadingState = .error(DataManagerError.operationFailed(entity: .task, action: .fetch))
                    }
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                Task { @MainActor in
                    self.tasks = snapshot.documents.compactMap { doc in
                        try? doc.data(as: UserTask.self)
                    }
                }
            }
        
        listeners.append(listener)
    }
    
    func startAllListeners() {
        guard isAuthenticated else { return }
        startListeningToTasks()
        // Any future listeners
    }
}

// MARK: - FirestoreRepositories
extension DataManager {
    private func setupRepositories() {
        taskRepository = FirestoreRepository(
            collection: db().collection("users").document(userId).collection("tasks")
        )
        habitRepository = FirestoreRepository(
            collection: db().collection("users").document(userId).collection("habits")
        )
        reminderRepository = FirestoreRepository(
            collection: db().collection("users").document(userId).collection("reminders")
        )
    }
}

