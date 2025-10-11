//
//  FocusDataManager.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import Foundation
import FirebaseFirestore
import Observation

@MainActor
@Observable class FocusDataManager {
    
    // MARK: - Properties
    var tasks: [UserTask] = []
    var focusSessions: [FocusSession] = []
    var habits: [Habit] = []
    var reminders: [Reminder] = []
    var currentInsights: UserInsights?
    
    var isLoading = false
    var errorMessage: String?
    
    private let userId: String
    
    // MARK: - Initialization
    init(userId: String) {
        self.userId = userId
    }
    
    // MARK: - Collection References
    private func tasksCollection() -> CollectionReference {
        return Firestore.firestore().collection("tasks")
    }
    
    private func focusSessionsCollection() -> CollectionReference {
        return Firestore.firestore().collection("focusSessions")
    }
    
    private func habitsCollection() -> CollectionReference {
        return Firestore.firestore().collection("habits")
    }
    
    private func remindersCollection() -> CollectionReference {
        return Firestore.firestore().collection("reminders")
    }
    
    private func dailyStatsCollection() -> CollectionReference {
        return Firestore.firestore().collection("dailyStats")
    }
    
    // MARK: - Task Management
    func createTask(_ task: UserTask) async throws {
        let encodedTask = try Firestore.Encoder().encode(task)
        guard let id = task.id else {
            fatalError("Task ID is malformed")
        }
        try await tasksCollection().document(id).setData(encodedTask)
        await fetchTasks()
    }
    
    func updateTask(_ task: UserTask) async throws {
        var updatedTask = task
        updatedTask.updatedAt = Date()
        let encodedTask = try Firestore.Encoder().encode(updatedTask)
        guard let id = task.id else {
            fatalError("Task ID is malformed")
        }
        try await tasksCollection().document(id).setData(encodedTask, merge: true)
        await fetchTasks()
    }
    
    func deleteTask(_ task: UserTask) async throws {
        guard let id = task.id else {
            fatalError("Task ID is malformed")
        }
        try await tasksCollection().document(id).delete()
        await fetchTasks()
    }
    
    func completeTask(_ task: UserTask) async throws {
        var completedTask = task
        completedTask.isCompleted = true
        completedTask.completedAt = Date()
        completedTask.updatedAt = Date()
        try await updateTask(completedTask)
    }
    
    func fetchTasks() async {
        isLoading = true
        do {
            let snapshot = try await tasksCollection()
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            self.tasks = snapshot.documents.compactMap { doc in
                try? doc.data(as: UserTask.self)
            }
        } catch {
            self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // MARK: - Focus Session Management
    func startFocusSession(_ session: FocusSession) async throws {
        var activeSession = session
        activeSession.status = .active
        activeSession.startTime = Date()
        
        let encodedSession = try Firestore.Encoder().encode(activeSession)
        guard let id = session.id else {
            fatalError("Focus Session ID is malformed")
        }
        try await focusSessionsCollection().document(id).setData(encodedSession)
        await fetchFocusSessions()
    }
    
    func pauseFocusSession(_ session: FocusSession) async throws {
        var pausedSession = session
        pausedSession.status = .paused
        pausedSession.pauseCount += 1
        pausedSession.updatedAt = Date()
        
        try await updateFocusSession(pausedSession)
    }
    
    func completeFocusSession(_ session: FocusSession, actualDuration: Int) async throws {
        var completedSession = session
        completedSession.status = .completed
        completedSession.endTime = Date()
        completedSession.actualDuration = actualDuration
        completedSession.updatedAt = Date()
        
        try await updateFocusSession(completedSession)
        
        // Update daily stats
        await updateDailyStats(focusTime: actualDuration)
    }
    
    func updateFocusSession(_ session: FocusSession) async throws {
        let encodedSession = try Firestore.Encoder().encode(session)
        guard let id = session.id else {
            fatalError("Focus Session ID is malformed")
        }
        try await focusSessionsCollection().document(id).setData(encodedSession, merge: true)
        await fetchFocusSessions()
    }
    
    func fetchFocusSessions() async {
        do {
            let snapshot = try await focusSessionsCollection()
                .whereField("userId", isEqualTo: userId)
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
        let encodedHabit = try Firestore.Encoder().encode(habit)
        guard let id = habit.id else {
            fatalError("Habit ID is malformed")
        }
        try await habitsCollection().document(id).setData(encodedHabit)
        await fetchHabits()
    }
    
    func completeHabit(_ habit: Habit, completion: HabitCompletion) async throws {
        // Create habit completion record
        let completionData = try Firestore.Encoder().encode(completion)
        try await Firestore.firestore()
            .collection("habitCompletions")
            .document(completion.id)
            .setData(completionData)
        
        // Update habit statistics
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
        let encodedHabit = try Firestore.Encoder().encode(habit)
        guard let id = habit.id else {
            fatalError("Havit ID is malformed")
        }
        try await habitsCollection().document(id).setData(encodedHabit, merge: true)
        await fetchHabits()
    }
    
    func fetchHabits() async {
        do {
            let snapshot = try await habitsCollection()
                .whereField("userId", isEqualTo: userId)
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
        let encodedReminder = try Firestore.Encoder().encode(reminder)
        guard let id = reminder.id else {
            fatalError("Habit ID is malformed")
        }
        try await remindersCollection().document(id).setData(encodedReminder)
        await fetchReminders()
    }
    
    func completeReminder(_ reminder: Reminder) async throws {
        var completedReminder = reminder
        completedReminder.isCompleted = true
        completedReminder.updatedAt = Date()
        
        let encodedReminder = try Firestore.Encoder().encode(completedReminder)
        guard let id = reminder.id else {
            fatalError("Habit ID is malformed")
        }
        try await remindersCollection().document(id).setData(encodedReminder, merge: true)
        await fetchReminders()
    }
    
    func snoozeReminder(_ reminder: Reminder, for minutes: Int) async throws {
        var snoozedReminder = reminder
        snoozedReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date()) ?? Date()
        snoozedReminder.snoozeCount += 1
        snoozedReminder.lastSnoozedAt = Date()
        snoozedReminder.updatedAt = Date()
        
        try await updateReminder(snoozedReminder)
    }
    
    func updateReminder(_ reminder: Reminder) async throws {
        let encodedReminder = try Firestore.Encoder().encode(reminder)
        guard let id = reminder.id else {
            fatalError("Habit ID is malformed")
        }
        try await remindersCollection().document(id).setData(encodedReminder, merge: true)
        await fetchReminders()
    }
    
    func fetchReminders() async {
        do {
            let snapshot = try await remindersCollection()
                .whereField("userId", isEqualTo: userId)
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
        // This would typically involve complex queries and calculations
        // For now, return a basic structure
        var insights = UserInsights(userId: userId, dateRange: dateRange)
        
        // Calculate basic statistics from current data
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
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = ISO8601DateFormatter()
        let todayString = dateFormatter.string(from: today)
        
        do {
            let statsRef = dailyStatsCollection().document("\(userId)_\(todayString)")
            try await statsRef.setData([
                "userId": userId,
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
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchTasks() }
            group.addTask { await self.fetchFocusSessions() }
            group.addTask { await self.fetchHabits() }
            group.addTask { await self.fetchReminders() }
        }
    }
}

// MARK: - Convenience Extensions
extension FocusDataManager {
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
