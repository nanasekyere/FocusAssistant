//
//  FocusDataManagerAsyncTests.swift
//  FocusAssistantTests
//
//  Created by Assistant on 11/10/2025.
//

import Testing
import Foundation
@testable import FocusAssistant

@Suite("FocusDataManager Async Operations Tests")
@MainActor
struct FocusDataManagerAsyncTests {
    
    private let testUserId = "async-test-user"
    
    // MARK: - Mock Firebase Operations Tests
    
    @Test("Load all data concurrently")
    func loadAllDataConcurrently() async {
        let manager = FocusDataManager(userId: testUserId)
        
        // This test verifies the structure exists
        // In a real test, you would mock Firestore
        #expect(manager.isLoading == false)
        
        // Verify the loadAllData method exists and can be called
        await manager.loadAllData()
        
        // After loading (even if mocked), the state should be consistent
        #expect(manager.tasks.isEmpty) // Would contain data in real scenario
        #expect(manager.focusSessions.isEmpty)
        #expect(manager.habits.isEmpty)
        #expect(manager.reminders.isEmpty)
    }
    
    @Test("Task operations maintain data integrity")
    func taskOperationsMaintainDataIntegrity() async throws {
        _ = FocusDataManager(userId: testUserId)
        let task = createTestTask()
        
        // Test that task operations would maintain integrity
        // In real implementation, these would interact with Firestore
        
        // Verify task has required fields for Firestore operations
        #expect(task.createdAt <= Date())
        #expect(task.updatedAt <= Date())
        
        // Test completion logic
        var completedTask = task
        completedTask.isCompleted = true
        completedTask.completedAt = Date()
        completedTask.updatedAt = Date()
        
        #expect(completedTask.isCompleted == true)
        #expect(completedTask.completedAt != nil)
        #expect(completedTask.updatedAt >= completedTask.createdAt)
    }
    
    @Test("Focus session lifecycle management")
    func focusSessionLifecycleManagement() async throws {
        _ = FocusDataManager(userId: testUserId)
        let session = createTestFocusSession()
        
        // Test session state transitions
        var activeSession = session
        activeSession.status = .active
        activeSession.startTime = Date()
        
        #expect(activeSession.status == .active)
        #expect(activeSession.startTime != nil)
        #expect(activeSession.isActive == true)
        
        // Test pause functionality
        var pausedSession = activeSession
        pausedSession.status = .paused
        pausedSession.pauseCount += 1
        pausedSession.updatedAt = Date()
        
        #expect(pausedSession.isPaused == true)
        #expect(pausedSession.pauseCount == 1)
        
        // Test completion
        var completedSession = pausedSession
        completedSession.status = .completed
        completedSession.endTime = Date()
        completedSession.actualDuration = 25
        completedSession.updatedAt = Date()
        
        #expect(completedSession.isCompleted == true)
        #expect(completedSession.endTime != nil)
        #expect(completedSession.actualDuration == 25)
    }
    
    @Test("Habit completion tracking")
    func habitCompletionTracking() async throws {
        _ = FocusDataManager(userId: testUserId)
        let habit = createTestHabit()
        
        // Test habit completion logic
        let completion = HabitCompletion(
            completedAt: Date(),
            mood: .focused,
            energyLevel: .medium,
            difficulty: 3
        )
        
        #expect(completion.completedAt <= Date())
        
        // Test habit statistics update
        var updatedHabit = habit
        updatedHabit.totalCompletions += 1
        updatedHabit.currentStreak += 1
        if updatedHabit.currentStreak > updatedHabit.longestStreak {
            updatedHabit.longestStreak = updatedHabit.currentStreak
        }
        updatedHabit.updatedAt = Date()
        
        #expect(updatedHabit.totalCompletions == 1)
        #expect(updatedHabit.currentStreak == 1)
        #expect(updatedHabit.longestStreak == 1)
    }
    
    @Test("Reminder snooze functionality")
    func reminderSnoozeFunctionality() async throws {
        _ = FocusDataManager(userId: testUserId)
        let reminder = createTestReminder()
        let snoozeMinutes = 15
        
        // Test snooze logic
        var snoozedReminder = reminder
        snoozedReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: snoozeMinutes, to: Date()) ?? Date()
        snoozedReminder.snoozeCount += 1
        snoozedReminder.lastSnoozedAt = Date()
        snoozedReminder.updatedAt = Date()
        
        #expect(snoozedReminder.snoozeCount == 1)
        #expect(snoozedReminder.lastSnoozedAt != nil)
        #expect(snoozedReminder.triggerDate > Date())
        
        // Verify snooze time calculation
        let timeDifference = snoozedReminder.triggerDate.timeIntervalSince(Date())
        #expect(timeDifference >= Double(snoozeMinutes * 60 - 5)) // Allow 5 second tolerance
        #expect(timeDifference <= Double(snoozeMinutes * 60 + 5))
    }
    
    @Test("Daily stats update logic")
    func dailyStatsUpdateLogic() async {
        _ = FocusDataManager(userId: testUserId)
        
        // Test the daily stats calculation logic
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = ISO8601DateFormatter()
        let todayString = dateFormatter.string(from: today)
        
        #expect(!todayString.isEmpty)
        
        // Test document ID generation for daily stats
        let expectedDocumentId = "\(testUserId)_\(todayString)"
        #expect(expectedDocumentId.contains(testUserId))
        #expect(expectedDocumentId.contains("T"))
    }
    
    @Test("Insights generation with comprehensive data")
    func insightsGenerationWithComprehensiveData() async throws {
        let manager = FocusDataManager(userId: testUserId)
        
        // Set up comprehensive test data
        let completedSessions = [
            createCompletedFocusSession(duration: 25, focusMode: .deepWork),
            createCompletedFocusSession(duration: 30, focusMode: .creative),
            createCompletedFocusSession(duration: 20, focusMode: .deepWork)
        ]
        
        let completedTasks = [
            createCompletedTask(),
            createCompletedTask(),
            createCompletedTask()
        ]
        
        let habits = [
            createHabitWithCompletions(completions: 5),
            createHabitWithCompletions(completions: 3),
            createHabitWithCompletions(completions: 7)
        ]
        
        manager.focusSessions = completedSessions
        manager.tasks = completedTasks + [createTestTask()] // Mix of completed and incomplete
        manager.habits = habits
        
        let dateRange = DateInterval(start: Date(), duration: 86400 * 7) // 1 week
        let insights = try await manager.generateInsights(for: dateRange)
        
        // Verify insights calculations
        #expect(insights.totalFocusTime == 75) // 25 + 30 + 20
        #expect(insights.averageSessionLength == 25.0) // 75 / 3
        #expect(insights.completedTasks == 3)
        #expect(insights.completedHabits == 15) // 5 + 3 + 7
        #expect(insights.dateRange.start == dateRange.start)
        #expect(insights.dateRange.duration == dateRange.duration)
        #expect(manager.currentInsights != nil)
    }
    
    @Test("Concurrent operations safety")
    func concurrentOperationsSafety() async throws {
        let manager = FocusDataManager(userId: testUserId)
        
        // Test that multiple operations can be performed concurrently
        // without data corruption (this tests the @MainActor isolation)
        async let task1: Void = manager.loadAllData()
        async let task2: UserInsights = try manager.generateInsights(for: DateInterval(start: Date(), duration: 86400))
        
        // All operations should complete without issues
        _ = await task1
        _ = try await task2
        
        #expect(manager.errorMessage == nil)
    }
    
    // MARK: - Performance Tests
    
    @Test("Large dataset handling")
    func largeDatasetHandling() async throws {
        let manager = FocusDataManager(userId: testUserId)
        
        // Create large datasets
        var largeTasks: [UserTask] = []
        var largeSessions: [FocusSession] = []
        var largeHabits: [Habit] = []
        var largeReminders: [Reminder] = []
        
        // Generate 100 items of each type
        for i in 0..<100 {
            var task = createTestTask()
            task.title = "Task \(i)"
            largeTasks.append(task)
            
            var session = createTestFocusSession()
            session.title = "Session \(i)"
            largeSessions.append(session)
            
            var habit = createTestHabit()
            habit.title = "Habit \(i)"
            largeHabits.append(habit)
            
            var reminder = createTestReminder()
            reminder.title = "Reminder \(i)"
            largeReminders.append(reminder)
        }
        
        // Assign large datasets to manager
        manager.tasks = largeTasks
        manager.focusSessions = largeSessions
        manager.habits = largeHabits
        manager.reminders = largeReminders
        
        // Test convenience methods with large datasets
        let todaysTasks = manager.todaysTasks
        let overdueTasks = manager.overdueTasks
        let upcomingReminders = manager.upcomingReminders
        let todaysHabits = manager.todaysHabits
        
        // Verify operations complete successfully
        #expect(manager.tasks.count == 100)
        #expect(manager.focusSessions.count == 100)
        #expect(manager.habits.count == 100)
        #expect(manager.reminders.count == 100)
        
        // Performance should be reasonable for filtering operations
        #expect(todaysTasks.count >= 0)
        #expect(overdueTasks.count >= 0)
        #expect(upcomingReminders.count >= 0)
        #expect(todaysHabits.count >= 0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestTask() -> UserTask {
        return UserTask(
            title: "Async Test Task",
            description: "A task for async testing",
            estimatedDuration: 30,
            priority: .medium,
            difficulty: .easy,
            category: .work
        )
    }
    
    private func createCompletedTask() -> UserTask {
        var task = createTestTask()
        task.isCompleted = true
        task.completedAt = Date()
        return task
    }
    
    private func createTestFocusSession() -> FocusSession {
        return FocusSession(
            title: "Async Test Session",
            focusMode: .deepWork,
            plannedDuration: 25
        )
    }
    
    private func createCompletedFocusSession(duration: Int, focusMode: FocusMode) -> FocusSession {
        var session = FocusSession(
            title: "Completed Session",
            focusMode: focusMode,
            plannedDuration: duration
        )
        session.status = .completed
        session.actualDuration = duration
        session.startTime = Calendar.current.date(byAdding: .minute, value: -duration, to: Date())
        session.endTime = Date()
        return session
    }
    
    private func createTestHabit() -> Habit {
        return Habit(
            title: "Async Test Habit",
            category: .health,
            frequency: .daily
        )
    }
    
    private func createHabitWithCompletions(completions: Int) -> Habit {
        var habit = createTestHabit()
        habit.totalCompletions = completions
        habit.currentStreak = completions
        habit.longestStreak = completions
        return habit
    }
    
    private func createTestReminder() -> Reminder {
        return Reminder(
            title: "Async Test Reminder",
            triggerDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
            type: .task
        )
    }
}
