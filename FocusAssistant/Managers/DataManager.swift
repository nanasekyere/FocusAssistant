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
    
    // MARK: - UI State
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
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
    
    // MARK: - Auth State Management
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
    
    // MARK: - Collection References
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
    
    // MARK: - Authentication Methods
    func signIn(withEmail email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            await loadAllData()
            showError = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            throw error
        }
    }
    
    func signUp(withEmail email: String, password: String, fullName: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            try usersCollection.document(user.id).setData(from: user)
            
            await fetchUser()
            showError = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            throw error
        }
    }
    
    func signOut() {
        do {
            isLoading = true
            defer { isLoading = false }
            
            try auth().signOut()
            clearUserData()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            throw error
        }
    }
    
    func deleteAccount() async throws {
        guard let user = auth().currentUser else {
            throw NSError(domain: "DataManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await usersCollection.document(user.uid).delete()
            await deleteUserData(userId: user.uid)
            try await user.delete()
            clearUserData()
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
            showError = true
            throw error
        }
    }
    
    func updateUserProfile(fullName: String) async throws {
        guard !userId.isEmpty else {
            throw NSError(domain: "DataManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        do {
            try await usersCollection.document(userId).updateData([
                "fullName": fullName
            ])
            currentUser?.fullName = fullName
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            throw error
        }
    }
    
    private func fetchUser() async {
        do {
            let snapshot = try await usersCollection.document(userId).getDocument()
            guard snapshot.exists else { return }
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            errorMessage = "Failed to fetch user data"
            showError = true
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
    
    // MARK: - Task Management
    func createTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        let encodedTask = try Firestore.Encoder().encode(task)
        guard let id = task.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
        }
        try await tasksCollection.document(id).setData(encodedTask)
        await fetchTasks()
    }
    
    func updateTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        var updatedTask = task
        updatedTask.updatedAt = Date()
        let encodedTask = try Firestore.Encoder().encode(updatedTask)
        guard let id = task.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
        }
        try await tasksCollection.document(id).setData(encodedTask, merge: true)
        await fetchTasks()
    }
    
    func deleteTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        guard let id = task.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Task ID is missing"])
        }
        try await tasksCollection.document(id).delete()
        await fetchTasks()
    }
    
    func completeTask(_ task: UserTask) async throws {
        guard isAuthenticated else { return }
        
        var completedTask = task
        completedTask.isCompleted = true
        completedTask.completedAt = Date()
        completedTask.updatedAt = Date()
        try await updateTask(completedTask)
        await updateDailyStats(completedTasks: 1)
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
            self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Focus Session Management
    func startFocusSession(_ session: FocusSession) async throws {
        guard isAuthenticated else { return }
        
        var activeSession = session
        activeSession.status = .active
        activeSession.startTime = Date()
        
        let encodedSession = try Firestore.Encoder().encode(activeSession)
        guard let id = session.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Session ID is missing"])
        }
        try await focusSessionsCollection.document(id).setData(encodedSession)
        await fetchFocusSessions()
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
        
        var completedSession = session
        completedSession.status = .completed
        completedSession.endTime = Date()
        completedSession.actualDuration = actualDuration
        completedSession.updatedAt = Date()
        
        try await updateFocusSession(completedSession)
        await updateDailyStats(focusTime: actualDuration)
    }
    
    func updateFocusSession(_ session: FocusSession) async throws {
        guard isAuthenticated else { return }
        
        let encodedSession = try Firestore.Encoder().encode(session)
        guard let id = session.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Session ID is missing"])
        }
        try await focusSessionsCollection.document(id).setData(encodedSession, merge: true)
        await fetchFocusSessions()
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
            self.errorMessage = "Failed to fetch focus sessions: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Habit Management
    func createHabit(_ habit: Habit) async throws {
        guard isAuthenticated else { return }
        
        let encodedHabit = try Firestore.Encoder().encode(habit)
        guard let id = habit.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Habit ID is missing"])
        }
        try await habitsCollection.document(id).setData(encodedHabit)
        await fetchHabits()
    }
    
    func completeHabit(_ habit: Habit, completion: HabitCompletion) async throws {
        guard isAuthenticated else { return }
        
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
    }
    
    func updateHabit(_ habit: Habit) async throws {
        guard isAuthenticated else { return }
        
        let encodedHabit = try Firestore.Encoder().encode(habit)
        guard let id = habit.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Habit ID is missing"])
        }
        try await habitsCollection.document(id).setData(encodedHabit, merge: true)
        await fetchHabits()
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
            self.errorMessage = "Failed to fetch habits: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Reminder Management
    func createReminder(_ reminder: Reminder) async throws {
        guard isAuthenticated else { return }
        
        let encodedReminder = try Firestore.Encoder().encode(reminder)
        guard let id = reminder.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder ID is missing"])
        }
        try await remindersCollection.document(id).setData(encodedReminder)
        await fetchReminders()
    }
    
    func completeReminder(_ reminder: Reminder) async throws {
        guard isAuthenticated else { return }
        
        var completedReminder = reminder
        completedReminder.isCompleted = true
        completedReminder.updatedAt = Date()
        
        let encodedReminder = try Firestore.Encoder().encode(completedReminder)
        guard let id = reminder.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder ID is missing"])
        }
        try await remindersCollection.document(id).setData(encodedReminder, merge: true)
        await fetchReminders()
    }
    
    func snoozeReminder(_ reminder: Reminder, for minutes: Int) async throws {
        guard isAuthenticated else { return }
        
        var snoozedReminder = reminder
        snoozedReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date()) ?? Date()
        snoozedReminder.snoozeCount += 1
        snoozedReminder.lastSnoozedAt = Date()
        snoozedReminder.updatedAt = Date()
        
        try await updateReminder(snoozedReminder)
    }
    
    func updateReminder(_ reminder: Reminder) async throws {
        guard isAuthenticated else { return }
        
        let encodedReminder = try Firestore.Encoder().encode(reminder)
        guard let id = reminder.id else {
            throw NSError(domain: "DataManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder ID is missing"])
        }
        try await remindersCollection.document(id).setData(encodedReminder, merge: true)
        await fetchReminders()
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
            self.errorMessage = "Failed to fetch reminders: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Analytics and Insights
    func generateInsights(for dateRange: DateInterval) async throws -> UserInsights {
        guard isAuthenticated else {
            throw NSError(domain: "DataManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
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
            print("Failed to update daily stats: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Loading
    func loadAllData() async {
        guard isAuthenticated else { return }
        guard !isTest else { return }
        isLoading = true
        defer { isLoading = false }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchTasks() }
            group.addTask { await self.fetchFocusSessions() }
            group.addTask { await self.fetchHabits() }
            group.addTask { await self.fetchReminders() }
        }
    }
    
    // MARK: - Real-time Listeners
    func startListeningToTasks() {
        guard isAuthenticated else { return }
        
        let listener = tasksCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "Failed to listen to tasks: \(error.localizedDescription)"
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
        // Any future listens
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
