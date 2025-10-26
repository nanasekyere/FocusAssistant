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

enum DataManagerError: LocalizedError {
    enum Entity: String {
        case user = "user"
        case task = "task"
        case focusSession = "focus session"
        case habit = "habit"
        case reminder = "reminder"
        case stats = "daily stats"
        case auth = "authentication"
    }
    enum Action: String {
        case fetch = "fetch"
        case create = "create"
        case update = "update"
        case delete = "delete"
        case complete = "complete"
        case uncomplete = "uncomplete"
        case start = "start"
        case pause = "pause"
        case signIn = "sign in"
        case signUp = "sign up"
        case signOut = "sign out"
        case resetPassword = "send password reset"
        case profileUpdate = "update profile"
        case load = "load"
        case snooze = "snooze"
    }

    case notAuthenticated
    case operationFailed(entity: Entity, action: Action)

    var errorDescription: String {
        switch self {
        case .notAuthenticated:
            return "Not authenticated"
        case let .operationFailed(entity, action):
            switch (entity, action) {
            case (.auth, .signIn): return "Failed to sign in"
            case (.auth, .signUp): return "Failed to sign up"
            case (.auth, .signOut): return "Failed to sign out"
            case (.auth, .resetPassword): return "Failed to send password reset"
            case (.user, .profileUpdate): return "Failed to update profile"
            case (.user, .delete): return "Failed to delete account"
            case (.user, .load): return "Failed to load data"
            case (.task, .fetch): return "Failed to fetch tasks"
            case (.task, .create): return "Failed to create task"
            case (.task, .update): return "Failed to update task"
            case (.task, .delete): return "Failed to delete task"
            case (.task, .complete): return "Failed to complete task"
            case (.task, .uncomplete): return "Failed to uncomplete task"
            case (.focusSession, .fetch): return "Failed to fetch focus sessions"
            case (.focusSession, .start): return "Failed to start focus session"
            case (.focusSession, .pause): return "Failed to pause focus session"
            case (.focusSession, .update): return "Failed to update focus session"
            case (.focusSession, .complete): return "Failed to complete focus session"
            case (.habit, .fetch): return "Failed to fetch habits"
            case (.habit, .create): return "Failed to create habit"
            case (.habit, .update): return "Failed to update habit"
            case (.habit, .complete): return "Failed to complete habit"
            case (.reminder, .fetch): return "Failed to fetch reminders"
            case (.reminder, .create): return "Failed to create reminder"
            case (.reminder, .update): return "Failed to update reminder"
            case (.reminder, .complete): return "Failed to complete reminder"
            case (.reminder, .snooze): return "Failed to snooze reminder"
            case (.stats, .update): return "Failed to update daily stats"
            default:
                return "Operation failed"
            }
        }
    }
}

enum LoadingState {
    case idle
    case loading
    case error(DataManagerError)
}

enum AlertError: Identifiable {
    case dataManagerError(DataManagerError)
    
    var id: String {
        switch self {
        case .dataManagerError(let error):
            return error.localizedDescription
        }
    }
    
    var title: String {
        "Error"
    }
    
    var message: String {
        switch self {
        case .dataManagerError(let error):
            return error.localizedDescription
        }
    }
}

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
    }
    
    func start() {
        setupAuthStateListener()
        checkCurrentUser()
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
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchTasks() }
            group.addTask { await self.fetchFocusSessions() }
            group.addTask { await self.fetchHabits() }
            group.addTask { await self.fetchReminders() }
        }
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
            await fetchUser()
            await loadAllData()
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .auth, action: .signIn))
            throw error
        }
    }
    
    func signUp(withEmail email: String, password: String, fullName: String) async throws {
        loadingState = .loading
        defer { loadingState = .idle }
        
        do {
            let result = try await auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            try usersCollection.document(user.id).setData(from: user)
            
            await fetchUser()
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
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .auth, action: .resetPassword))
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
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .user, action: .profileUpdate))
            throw error
        }
    }
    
    private func fetchUser() async {
        do {
            let snapshot = try await usersCollection.document(userId).getDocument()
            guard snapshot.exists else { return }
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            loadingState = .error(DataManagerError.operationFailed(entity: .user, action: .fetch))
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
                    await self?.fetchUser()
                    await self?.loadAllData()
                } else {
                    self?.clearUserData()
                }
            }
        }
    }
    
    func checkCurrentUser() {
        self.userSession = auth().currentUser
        if userSession != nil {
            Task {
                await fetchUser()
                await loadAllData()
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
        guard isAuthenticated else { return }
        
        do {
            let encodedTask = try Firestore.Encoder().encode(task)
            guard let id = task.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
            }
            try await tasksCollection.document(id).setData(encodedTask)
            await fetchTasks()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .task, action: .create))
            throw error
        }
    }
    
    func updateTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        do {
            var updatedTask = task
            updatedTask.updatedAt = Date()
            let encodedTask = try Firestore.Encoder().encode(updatedTask)
            guard let id = task.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
            }
            try await tasksCollection.document(id).setData(encodedTask, merge: true)
            await fetchTasks()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .task, action: .update))
            throw error
        }
    }
    
    func deleteTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        do {
            guard let id = task.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
            }
            try await tasksCollection.document(id).delete()
            await fetchTasks()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .task, action: .delete))
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
            await updateDailyStats(completedTasks: 1)
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .task, action: .complete))
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
            await updateDailyStats(completedTasks: -1)
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .task, action: .uncomplete))
            throw error
        }
    }
    
    func fetchTasks() async {
        guard isAuthenticated else { return }
        do {
            let snapshot = try await tasksCollection
                .order(by: "createdAt", descending: true)
                .getDocuments()
            self.tasks = snapshot.documents.compactMap { doc in
                try? doc.data(as: UserTask.self)
            }
        } catch {
            self.loadingState = .error(DataManagerError.operationFailed(entity: .task, action: .fetch))
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
            await fetchFocusSessions()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .focusSession, action: .start))
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
            await updateDailyStats(focusTime: actualDuration)
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .focusSession, action: .complete))
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
            await fetchFocusSessions()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .focusSession, action: .update))
            throw error
        }
    }
    
    func fetchFocusSessions() async {
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
            self.loadingState = .error(DataManagerError.operationFailed(entity: .focusSession, action: .fetch))
        }
    }
    
}

// MARK: - Habit Management
extension DataManager {
    func createHabit(_ habit: Habit) async throws {
        guard isAuthenticated else { return }
        
        do {
            let encodedHabit = try Firestore.Encoder().encode(habit)
            guard let id = habit.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Habit ID is missing"])
            }
            try await habitsCollection.document(id).setData(encodedHabit)
            await fetchHabits()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .habit, action: .create))
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
            await updateDailyStats(completedHabits: 1)
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .habit, action: .complete))
            throw error
        }
    }
    
    func updateHabit(_ habit: Habit) async throws {
        guard isAuthenticated else { return }
        
        do {
            let encodedHabit = try Firestore.Encoder().encode(habit)
            guard let id = habit.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Habit ID is missing"])
            }
            try await habitsCollection.document(id).setData(encodedHabit, merge: true)
            await fetchHabits()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .habit, action: .update))
            throw error
        }
    }
    
    func fetchHabits() async {
        guard isAuthenticated else { return }
        
        do {
            let snapshot = try await habitsCollection
                .whereField("isActive", isEqualTo: true)
                .getDocuments()
            
            self.habits = snapshot.documents.compactMap { doc in
                try? doc.data(as: Habit.self)
            }
        } catch {
            self.loadingState = .error(DataManagerError.operationFailed(entity: .habit, action: .fetch))
        }
    }
}

// MARK: - Reminder Management
extension DataManager {
    func createReminder(_ reminder: Reminder) async throws {
        guard isAuthenticated else { return }
        
        do {
            let encodedReminder = try Firestore.Encoder().encode(reminder)
            guard let id = reminder.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder ID is missing"])
            }
            try await remindersCollection.document(id).setData(encodedReminder)
            await fetchReminders()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .reminder, action: .create))
            throw error
        }
    }
    
    func completeReminder(_ reminder: Reminder) async throws {
        guard isAuthenticated else { return }
        
        do {
            var completedReminder = reminder
            completedReminder.isCompleted = true
            completedReminder.updatedAt = Date()
            
            let encodedReminder = try Firestore.Encoder().encode(completedReminder)
            guard let id = reminder.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder ID is missing"])
            }
            try await remindersCollection.document(id).setData(encodedReminder, merge: true)
            await fetchReminders()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .reminder, action: .complete))
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
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .reminder, action: .snooze))
            throw error
        }
    }
    
    func updateReminder(_ reminder: Reminder) async throws {
        guard isAuthenticated else { return }
        
        do {
            let encodedReminder = try Firestore.Encoder().encode(reminder)
            guard let id = reminder.id else {
                throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder ID is missing"])
            }
            try await remindersCollection.document(id).setData(encodedReminder, merge: true)
            await fetchReminders()
        } catch {
            alertError = AlertError.dataManagerError(DataManagerError.operationFailed(entity: .reminder, action: .update))
            throw error
        }
    }
    
    func fetchReminders() async {
        guard isAuthenticated else { return }
        
        do {
            let snapshot = try await remindersCollection
                .whereField("isCompleted", isEqualTo: false)
                .order(by: "triggerDate")
                .getDocuments()
            
            self.reminders = snapshot.documents.compactMap { doc in
                try? doc.data(as: Reminder.self)
            }
        } catch {
            self.loadingState = .error(DataManagerError.operationFailed(entity: .reminder, action: .fetch))
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
    
    private func updateDailyStats(focusTime: Int = 0, completedTasks: Int = 0, completedHabits: Int = 0) async {
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
            loadingState = .error(DataManagerError.operationFailed(entity: .stats, action: .update))
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

