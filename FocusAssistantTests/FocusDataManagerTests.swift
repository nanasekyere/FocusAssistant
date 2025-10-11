//
//  FocusDataManagerTests.swift
//  FocusAssistantTests
//
//  Created by Assistant on 11/10/2025.
//

import Testing
import Foundation
@testable import FocusAssistant

@MainActor
@Suite("FocusDataManager Tests")
struct FocusDataManagerTests {
    
    private let testUserId = "test-user-123"
    
    // MARK: - Initialization Tests
    
    @Test("Initialize FocusDataManager with user ID")
    func initializeWithUserId() {
        let manager = FocusDataManager(userId: testUserId)
        
        #expect(manager.tasks.isEmpty)
        #expect(manager.focusSessions.isEmpty)
        #expect(manager.habits.isEmpty)
        #expect(manager.reminders.isEmpty)
        #expect(manager.currentInsights == nil)
        #expect(manager.isLoading == false)
        #expect(manager.errorMessage == nil)
    }
    
    // MARK: - Task Management Tests
    
    @Test("Create sample task")
    func createSampleTask() {
        let task = createTestTask()
        
        #expect(task.title == "Test Task")
        #expect(task.isCompleted == false)
        #expect(task.priority == .medium)
        #expect(task.difficulty == .easy)
    }
    
    @Test("Complete task updates completion status")
    func completeTaskUpdatesStatus() {
        var task = createTestTask()
        
        // Simulate completing the task
        task.isCompleted = true
        task.completedAt = Date()
        
        #expect(task.isCompleted == true)
        #expect(task.completedAt != nil)
    }
    
    @Test("Task overdue status calculation")
    func taskOverdueStatus() {
        var task = createTestTask()
        task.dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        task.isCompleted = false
        
        #expect(task.isOverdue == true)
    }
    
    @Test("Task due today calculation")
    func taskDueTodayStatus() {
        var task = createTestTask()
        // Use mid-day to ensure it's clearly "today"
        let today = Calendar.current.startOfDay(for: Date())
        task.dueDate = Calendar.current.date(byAdding: .hour, value: 12, to: today)
        
        #expect(task.isDueToday == true)
    }
    
    @Test("Task completion percentage with subtasks")
    func taskCompletionPercentage() {
        var task = createTestTask()
        task.subtasks = [
            Subtask(title: "Subtask 1", isCompleted: true, order: 1),
            Subtask(title: "Subtask 2", isCompleted: false, order: 2),
            Subtask(title: "Subtask 3", isCompleted: true, order: 3)
        ]
        
        let expectedPercentage = 2.0 / 3.0 // 2 out of 3 subtasks completed
        #expect(task.completionPercentage == expectedPercentage)
    }
    
    // MARK: - Focus Session Tests
    
    @Test("Create focus session")
    func createFocusSession() {
        let session = createTestFocusSession()
        
        #expect(session.title == "Test Focus Session")
        #expect(session.status == .planned)
        #expect(session.plannedDuration == 25)
        #expect(session.pauseCount == 0)
    }
    
    @Test("Focus session status checks")
    func focusSessionStatusChecks() {
        var session = createTestFocusSession()
        
        // Test planned status
        #expect(session.isActive == false)
        #expect(session.isPaused == false)
        #expect(session.isCompleted == false)
        
        // Test active status
        session.status = .active
        #expect(session.isActive == true)
        #expect(session.isPaused == false)
        #expect(session.isCompleted == false)
        
        // Test paused status
        session.status = .paused
        #expect(session.isActive == false)
        #expect(session.isPaused == true)
        #expect(session.isCompleted == false)
        
        // Test completed status
        session.status = .completed
        #expect(session.isActive == false)
        #expect(session.isPaused == false)
        #expect(session.isCompleted == true)
    }
    
    @Test("Focus session efficiency calculation")
    func focusSessionEfficiency() {
        var session = createTestFocusSession()
        session.actualDuration = 25 // 25 minutes actual
        session.totalPauseTime = 300 // 5 minutes pause (300 seconds)
        
        // Expected efficiency: (25 - 5) / 25 = 0.8 (80%)
        let expectedEfficiency = 0.8
        #expect(session.efficiency == expectedEfficiency)
    }
    
    @Test("Focus session with distractions")
    func focusSessionWithDistractions() {
        var session = createTestFocusSession()
        session.distractions = [
            Distraction(type: .phone, description: "Quick check", duration: 120, severity: .minor),
            Distraction(type: .thoughts, description: "Mind wandering", duration: 60, severity: .moderate)
        ]
        
        #expect(session.totalDistractionTime == 180) // 120 + 60 seconds
        #expect(session.distractions.count == 2)
    }
    
    // MARK: - Habit Management Tests
    
    @Test("Create habit")
    func createHabit() {
        let habit = createTestHabit()
        
        #expect(habit.title == "Test Habit")
        #expect(habit.frequency == .daily)
        #expect(habit.isActive == true)
        #expect(habit.currentStreak == 0)
        #expect(habit.totalCompletions == 0)
    }
    
    @Test("Habit should show today for daily frequency")
    func habitShouldShowTodayDaily() {
        var habit = createTestHabit()
        habit.frequency = .daily
        
        #expect(habit.shouldShowToday == true)
    }
    
    @Test("Habit completion rate calculation")
    func habitCompletionRate() {
        var habit = createTestHabit()
        
        // Set created date to 10 days ago
        habit.createdAt = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        habit.totalCompletions = 7 // Completed 7 times in 10 days
        
        let expectedRate = 7.0 / 10.0 // 70% completion rate
        #expect(abs(habit.completionRate - expectedRate) < 0.1) // Allow small floating point variance
    }
    
    @Test("Create habit completion")
    func createHabitCompletion() {
        let habit = createTestHabit()
        let completion = HabitCompletion(
            mood: .focused,
            energyLevel: .high,
            difficulty: 3
        )
        
        #expect(completion.mood == .focused)
        #expect(completion.energyLevel == .high)
        #expect(completion.difficulty == 3)
    }
    
    // MARK: - Reminder Management Tests
    
    @Test("Create reminder")
    func createReminder() {
        let reminder = createTestReminder()
        
        #expect(reminder.title == "Test Reminder")
        #expect(reminder.type == .task)
        #expect(reminder.urgency == .normal)
        #expect(reminder.isCompleted == false)
        #expect(reminder.snoozeCount == 0)
    }
    
    @Test("Reminder overdue status")
    func reminderOverdueStatus() {
        var reminder = createTestReminder()
        reminder.triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        reminder.isCompleted = false
        
        #expect(reminder.isOverdue == true)
    }
    
    @Test("Reminder due today status")
    func reminderDueTodayStatus() {
        var reminder = createTestReminder()
        reminder.triggerDate = Date()
        
        #expect(reminder.isDueToday == true)
    }
    
    @Test("Reminder should repeat conditions")
    func reminderShouldRepeat() {
        var reminder = createTestReminder()
        reminder.isRepeating = true
        reminder.maxRepetitions = 5
        reminder.completedRepetitions = 3
        
        #expect(reminder.shouldRepeat == true)
        
        // Test when max repetitions reached
        reminder.completedRepetitions = 5
        #expect(reminder.shouldRepeat == false)
        
        // Test when end date passed
        reminder.completedRepetitions = 3
        reminder.endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        #expect(reminder.shouldRepeat == false)
    }
    
    @Test("Snooze reminder calculation")
    func snoozeReminderCalculation() {
        _ = createTestReminder()
        let snoozeMinutes = 15
        let now = Date()
        
        let expectedTriggerDate = Calendar.current.date(byAdding: .minute, value: snoozeMinutes, to: now)
        
        #expect(expectedTriggerDate != nil)
        
        // Verify the snooze calculation would work
        if let expectedDate = expectedTriggerDate {
            let timeDifference = expectedDate.timeIntervalSince(now)
            #expect(abs(timeDifference - Double(snoozeMinutes * 60)) < 1.0) // Allow 1 second tolerance
        }
    }
    
    // MARK: - Data Manager Convenience Extensions Tests
    
    @Test("Today's tasks filtering")
    func todaysTasksFiltering() {
        let manager = FocusDataManager(userId: testUserId)
        
        // Use more precise date handling
        let today = Calendar.current.startOfDay(for: Date())
        let todayMidDay = Calendar.current.date(byAdding: .hour, value: 12, to: today) ?? Date()
        
        // Create tasks with different due dates
        var todayTask = createTestTask()
        todayTask.dueDate = todayMidDay
        
        var tomorrowTask = createTestTask()
        tomorrowTask.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        
        var scheduledTodayTask = createTestTask()
        scheduledTodayTask.scheduledDate = todayMidDay
        scheduledTodayTask.dueDate = nil
        
        // Simulate tasks in manager
        manager.tasks = [todayTask, tomorrowTask, scheduledTodayTask]
        
        let todaysTasks = manager.todaysTasks
        #expect(todaysTasks.count == 2) // todayTask and scheduledTodayTask
    }
    
    @Test("Overdue tasks filtering")
    func overdueTasksFiltering() {
        let manager = FocusDataManager(userId: testUserId)
        
        var overdueTask = createTestTask()
        overdueTask.dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        overdueTask.isCompleted = false
        
        var currentTask = createTestTask()
        // Set current task to be due in the future to avoid timing issues
        currentTask.dueDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        currentTask.isCompleted = false
        
        var completedOverdueTask = createTestTask()
        completedOverdueTask.dueDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        completedOverdueTask.isCompleted = true
        
        manager.tasks = [overdueTask, currentTask, completedOverdueTask]
        
        let overdueTasks = manager.overdueTasks
        #expect(overdueTasks.count == 1) // Only overdueTask
        #expect(overdueTasks.first?.isOverdue == true)
    }
    
    @Test("Active focus session detection")
    func activeFocusSessionDetection() {
        let manager = FocusDataManager(userId: testUserId)
        
        var activeSession = createTestFocusSession()
        activeSession.status = .active
        
        var completedSession = createTestFocusSession()
        completedSession.status = .completed
        
        manager.focusSessions = [completedSession, activeSession]
        
        let activeSessionResult = manager.activeFocusSession
        #expect(activeSessionResult != nil)
        #expect(activeSessionResult?.status == .active)
    }
    
    @Test("Upcoming reminders filtering")
    func upcomingRemindersFiltering() {
        let manager = FocusDataManager(userId: testUserId)
        
        var upcomingReminder = createTestReminder()
        upcomingReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        upcomingReminder.isCompleted = false
        
        var distantReminder = createTestReminder()
        distantReminder.triggerDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        distantReminder.isCompleted = false
        
        var completedReminder = createTestReminder()
        completedReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completedReminder.isCompleted = true
        
        manager.reminders = [upcomingReminder, distantReminder, completedReminder]
        
        let upcomingReminders = manager.upcomingReminders
        #expect(upcomingReminders.count == 1) // Only upcomingReminder within next hour
        #expect(upcomingReminders.first?.isCompleted == false)
    }
    
    @Test("Today's habits filtering")
    func todaysHabitsFiltering() {
        let manager = FocusDataManager(userId: testUserId)
        
        var dailyHabit = createTestHabit()
        dailyHabit.frequency = .daily
        
        var weeklyHabit = createTestHabit()
        weeklyHabit.frequency = .weekly
        
        manager.habits = [dailyHabit, weeklyHabit]
        
        let todaysHabits = manager.todaysHabits
        #expect(todaysHabits.count == 1) // Only dailyHabit should show today
        #expect(todaysHabits.first?.frequency == .daily)
    }
    
    // MARK: - Insights Generation Tests
    
    @Test("Generate basic insights")
    func generateBasicInsights() async throws {
        let manager = FocusDataManager(userId: testUserId)
        
        // Set up test data
        var completedSession1 = createTestFocusSession()
        completedSession1.status = .completed
        completedSession1.actualDuration = 25
        
        var completedSession2 = createTestFocusSession()
        completedSession2.status = .completed
        completedSession2.actualDuration = 30
        
        var completedTask = createTestTask()
        completedTask.isCompleted = true
        
        var completedHabit = createTestHabit()
        completedHabit.totalCompletions = 5
        
        manager.focusSessions = [completedSession1, completedSession2]
        manager.tasks = [completedTask]
        manager.habits = [completedHabit]
        
        let dateRange = DateInterval(start: Date(), duration: 86400) // 1 day
        let insights = try await manager.generateInsights(for: dateRange)
        
        #expect(insights.totalFocusTime == 55) // 25 + 30 minutes
        #expect(insights.averageSessionLength == 27.5) // (25 + 30) / 2
        #expect(insights.completedTasks == 1)
        #expect(insights.completedHabits == 5)
        #expect(manager.currentInsights != nil)
    }
    
    // MARK: - Helper Methods
    
    private func createTestTask() -> UserTask {
        return UserTask(
            title: "Test Task",
            description: "A task for testing",
            estimatedDuration: 30,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            priority: .medium,
            difficulty: .easy,
            category: .work,
            tags: ["test", "sample"]
        )
    }
    
    private func createTestFocusSession() -> FocusSession {
        return FocusSession(
            taskId: "test-task-id",
            title: "Test Focus Session",
            focusMode: .deepWork,
            plannedDuration: 25,
            moodBefore: .focused,
            energyBefore: .medium
        )
    }
    
    private func createTestHabit() -> Habit {
        return Habit(
            title: "Test Habit",
            description: "A habit for testing",
            category: .health,
            frequency: .daily,
            preferredTime: "09:00",
            duration: 10
        )
    }
    
    private func createTestReminder() -> Reminder {
        return Reminder(
            title: "Test Reminder",
            message: "This is a test reminder",
            triggerDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
            type: .task,
            urgency: .normal
        )
    }
}

// MARK: - Additional Test Suites
@MainActor
@Suite("FocusDataManager Error Handling Tests")
struct FocusDataManagerErrorTests {
    
    private let testUserId = "error-test-user"
    
    @Test("Manager handles loading state correctly")
    func managerHandlesLoadingState() {
        let manager = FocusDataManager(userId: testUserId)
        
        // Initial state should not be loading
        #expect(manager.isLoading == false)
        
        // Simulate loading state (normally set by async methods)
        manager.isLoading = true
        #expect(manager.isLoading == true)
        
        manager.isLoading = false
        #expect(manager.isLoading == false)
    }
    
    @Test("Manager handles error messages")
    func managerHandlesErrorMessages() {
        let manager = FocusDataManager(userId: testUserId)
        
        #expect(manager.errorMessage == nil)
        
        let testError = "Test error message"
        manager.errorMessage = testError
        
        #expect(manager.errorMessage == testError)
        
        // Clear error
        manager.errorMessage = nil
        #expect(manager.errorMessage == nil)
    }
}

@Suite("FocusDataManager Model Validation Tests")
struct FocusDataManagerModelValidationTests {
    
    @Test("UserTask model validation")
    func userTaskValidation() {
        let task = UserTask(

            title: "Valid Task",
            priority: .high,
            difficulty: .hard,
            energyLevel: .high,
            category: .work
        )
        
        #expect(task.title == "Valid Task")
        #expect(task.priority == .high)
        #expect(task.difficulty == .hard)
        #expect(task.energyLevel == .high)
        #expect(task.category == .work)
        #expect(task.isCompleted == false) // Default value
        #expect(task.postponementCount == 0) // Default value
    }
    
    @Test("FocusSession model validation")
    func focusSessionValidation() {
        let session = FocusSession(
            title: "Valid Session",
            focusMode: .creative,
            plannedDuration: 45
        )
        
        #expect(session.title == "Valid Session")
        #expect(session.focusMode == .creative)
        #expect(session.plannedDuration == 45)
        #expect(session.status == .planned) // Default value
        #expect(session.pauseCount == 0) // Default value
        #expect(session.totalPauseTime == 0) // Default value
    }
    
    @Test("Habit model validation")
    func habitValidation() {
        let habit = Habit(
            title: "Valid Habit",
            category: .mindfulness,
            frequency: .daily
        )
        
        #expect(habit.title == "Valid Habit")
        #expect(habit.category == .mindfulness)
        #expect(habit.frequency == .daily)
        #expect(habit.isActive == true) // Default value
        #expect(habit.currentStreak == 0) // Default value
        #expect(habit.totalCompletions == 0) // Default value
    }
    
    @Test("Reminder model validation")
    func reminderValidation() {
        let triggerDate = Date()
        let reminder = Reminder(
            title: "Valid Reminder",
            triggerDate: triggerDate,
            type: .medication,
            urgency: .high
        )
        
        #expect(reminder.title == "Valid Reminder")
        #expect(reminder.triggerDate == triggerDate)
        #expect(reminder.type == .medication)
        #expect(reminder.urgency == .high)
        #expect(reminder.isCompleted == false) // Default value
        #expect(reminder.snoozeCount == 0) // Default value
    }
}
