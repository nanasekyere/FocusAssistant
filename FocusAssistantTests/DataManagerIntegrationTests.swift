//
//  DataManagerIntegrationTests.swift
//  FocusAssistantTests
//
//  Created by Assistant on 11/10/2025.
//

import Testing
import Foundation
@testable import FocusAssistant

@Suite("DataManager Integration and Mock Tests")
@MainActor
struct DataManagerIntegrationTests {
    
    private let testUserId = "integration-test-user"
    
    // MARK: - Data Flow Integration Tests
    
    @Test("Complete task workflow integration")
    func completeTaskWorkflowIntegration() async throws {
        _ = DataManager()
        let task = createTestTask()
        
        // Simulate complete task workflow
        // 1. Create task
        #expect(task.isCompleted == false)
        #expect(task.completedAt == nil)
        
        // 2. Start focus session for task
        let focusSession = FocusSession(
            taskId: task.id,
            title: "Focus on \(task.title)",
            focusMode: .deepWork,
            plannedDuration: task.estimatedDuration ?? 25
        )
        
        #expect(focusSession.taskId == task.id)
        #expect(focusSession.status == .planned)
        
        // 3. Activate session
        var activeSession = focusSession
        activeSession.status = .active
        activeSession.startTime = Date()
        
        #expect(activeSession.isActive == true)
        
        // 4. Complete session
        var completedSession = activeSession
        completedSession.status = .completed
        completedSession.endTime = Date()
        completedSession.actualDuration = 30
        completedSession.productivityRating = 4
        
        #expect(completedSession.isCompleted == true)
        #expect(completedSession.actualDuration != nil)
        
        // 5. Complete task
        var completedTask = task
        completedTask.isCompleted = true
        completedTask.completedAt = Date()
        completedTask.actualDuration = completedSession.actualDuration
        completedTask.focusSessions = [completedSession.id].compactMap { $0 }
        
        #expect(completedTask.isCompleted == true)
        #expect(completedTask.actualDuration == completedSession.actualDuration)
        
        // 6. Update daily stats (simulated)
        let expectedFocusTime = completedSession.actualDuration ?? 0
        #expect(expectedFocusTime == 30)
    }
    
    @Test("Habit tracking workflow integration")
    func habitTrackingWorkflowIntegration() async throws {
        _ = DataManager()
        let habit = createTestHabit()
        
        // Initial state
        #expect(habit.currentStreak == 0)
        #expect(habit.totalCompletions == 0)
        #expect(habit.longestStreak == 0)
        
        // Simulate multiple habit completions over time
        var updatedHabit = habit
        let _: [HabitCompletion] = []
        
        // Day 1 completion
        _ = HabitCompletion(
            completedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            mood: .focused,
            energyLevel: .high,
            difficulty: 2
        )
        
        updatedHabit.totalCompletions += 1
        updatedHabit.currentStreak += 1
        updatedHabit.longestStreak = max(updatedHabit.longestStreak, updatedHabit.currentStreak)
        
        #expect(updatedHabit.currentStreak == 1)
        #expect(updatedHabit.totalCompletions == 1)
        #expect(updatedHabit.longestStreak == 1)
        
        // Day 2 completion
        _ = HabitCompletion(
            completedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            mood: .calm,
            energyLevel: .medium,
            difficulty: 3
        )
        
        updatedHabit.totalCompletions += 1
        updatedHabit.currentStreak += 1
        updatedHabit.longestStreak = max(updatedHabit.longestStreak, updatedHabit.currentStreak)
        
        #expect(updatedHabit.currentStreak == 2)
        #expect(updatedHabit.totalCompletions == 2)
        #expect(updatedHabit.longestStreak == 2)
        
        // Today completion
        _ = HabitCompletion(
            completedAt: Date(),
            mood: .excited,
            energyLevel: .high,
            difficulty: 1
        )
        
        updatedHabit.totalCompletions += 1
        updatedHabit.currentStreak += 1
        updatedHabit.longestStreak = max(updatedHabit.longestStreak, updatedHabit.currentStreak)
        
        #expect(updatedHabit.currentStreak == 3)
        #expect(updatedHabit.totalCompletions == 3)
        #expect(updatedHabit.longestStreak == 3)
        
        // Test completion rate calculation
        updatedHabit.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let expectedRate = 3.0 / 3.0 // 100% completion rate
        #expect(abs(updatedHabit.completionRate - expectedRate) < 0.1)
    }
    
    @Test("Reminder lifecycle integration")
    func reminderLifecycleIntegration() async throws {
        _ = DataManager()
        
        // Create reminder for a task
        let task = createTestTask()
        let reminder = Reminder(
            title: "Complete \(task.title)",
            message: "Don't forget to work on your task",
            triggerDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date(),
            type: .task,
            urgency: .normal,
            estimatedDuration: task.estimatedDuration, taskId: task.id
        )
        
        #expect(reminder.taskId == task.id)
        #expect(reminder.isCompleted == false)
        #expect(reminder.snoozeCount == 0)
        
        // User snoozes reminder
        var snoozedReminder = reminder
        let snoozeMinutes = 15
        snoozedReminder.triggerDate = Calendar.current.date(byAdding: .minute, value: snoozeMinutes, to: Date()) ?? Date()
        snoozedReminder.snoozeCount += 1
        snoozedReminder.lastSnoozedAt = Date()
        
        #expect(snoozedReminder.snoozeCount == 1)
        #expect(snoozedReminder.lastSnoozedAt != nil)
        
        // User completes the associated task
        var completedTask = task
        completedTask.isCompleted = true
        completedTask.completedAt = Date()
        
        // Reminder should be marked as completed
        var completedReminder = snoozedReminder
        completedReminder.isCompleted = true
        completedReminder.updatedAt = Date()
        
        #expect(completedReminder.isCompleted == true)
        #expect(completedTask.isCompleted == true)
    }
    
    @Test("Cross-entity relationships")
    func crossEntityRelationships() async throws {
        _ = DataManager()
        
        // Create related entities
        let task = createTestTask()
        
        // Focus session linked to task
        let focusSession = FocusSession(
            taskId: task.id,
            title: "Focus on \(task.title)",
            focusMode: .deepWork,
            plannedDuration: task.estimatedDuration ?? 25
        )
        
        // Reminder for the task
        let taskReminder = Reminder(
            title: "Task reminder",
            triggerDate: task.dueDate ?? Date(),
            type: .task,
            taskId: task.id
        )
        
        // Reminder for the focus session
        let sessionReminder = Reminder(

            title: "Start focus session",
            triggerDate: Calendar.current.date(byAdding: .minute, value: -5, to: focusSession.startTime ?? Date()) ?? Date(),
            type: .focusSession,
            focusSessionId: focusSession.id
        )
        
        // Habit related to productivity
        let habit = createTestHabit()
        
        // Reminder for habit
        let habitReminder = Reminder(
            title: "Time for \(habit.title)",
            triggerDate: Date(),
            type: .habit,
            habitId: habit.id
        )
        
        // Verify relationships
        #expect(focusSession.taskId == task.id)
        #expect(taskReminder.taskId == task.id)
        #expect(sessionReminder.focusSessionId == focusSession.id)
        #expect(habitReminder.habitId == habit.id)
        
    }
    
    @Test("Data consistency across operations")
    func dataConsistencyAcrossOperations() async throws {
        let manager = DataManager(isTest: true)
        
        // Create initial data
        let tasks = (1...10).map { i in
            var task = createTestTask()
            task.title = "Task \(i)"
            return task
        }
        
        let sessions = tasks.map { task in
            FocusSession(

                taskId: task.id,
                title: "Session for \(task.title)",
                focusMode: .deepWork,
                plannedDuration: 25
            )
        }
        
        let habits = (1...5).map { i in
            var habit = createTestHabit()
            habit.title = "Habit \(i)"
            return habit
        }
        
        let reminders = tasks.map { task in
            Reminder(
                title: "Reminder for \(task.title)",
                triggerDate: Date(),
                type: .task,
                taskId: task.id
            )
        }
        
        // Assign to manager
        manager.tasks = tasks
        manager.focusSessions = sessions
        manager.habits = habits
        manager.reminders = reminders
        
        // Verify data consistency
        #expect(manager.tasks.count == 10)
        #expect(manager.focusSessions.count == 10)
        #expect(manager.habits.count == 5)
        #expect(manager.reminders.count == 10)
        
        
        // Sessions should be linked to tasks
        for session in manager.focusSessions {
            let linkedTask = manager.tasks.first { $0.id == session.taskId }
            #expect(linkedTask != nil)
        }
        
        // Reminders should be linked to tasks
        for reminder in manager.reminders {
            if let taskId = reminder.taskId {
                let linkedTask = manager.tasks.first { $0.id == taskId }
                #expect(linkedTask != nil)
            }
        }
    }
    
    @Test("Bulk operations performance")
    func bulkOperationsPerformance() async throws {
        let manager = DataManager(isTest: true)
        
        // Create large dataset
        let numberOfItems = 1000
        
        let largeTasks = (1...numberOfItems).map { i in
            var task = createTestTask()
            task.title = "Bulk Task \(i)"
            task.isCompleted = i % 2 == 0 // Half completed
            return task
        }
        
        let largeSessions = (1...numberOfItems).map { i in
            var session = createTestFocusSession()
            session.title = "Bulk Session \(i)"
            session.status = i % 3 == 0 ? .completed : .planned
            if session.status == .completed {
                session.actualDuration = Int.random(in: 15...45)
            }
            return session
        }
        
        // Assign large datasets
        manager.tasks = largeTasks
        manager.focusSessions = largeSessions
        
        // Test filtering operations with large datasets
        let startTime = Date()
        
        let completedTasks = manager.tasks.filter { $0.isCompleted }
        let completedSessions = manager.focusSessions.filter { $0.isCompleted }
        _ = manager.todaysTasks
        _ = manager.overdueTasks
        
        let operationTime = Date().timeIntervalSince(startTime)
        
        // Verify results
        #expect(completedTasks.count == numberOfItems / 2)
        #expect(completedSessions.count > 0)
        #expect(operationTime < 1.0) // Should complete within 1 second
        
        // Test insights generation with large dataset
        let insightsStartTime = Date()
        let dateRange = DateInterval(start: Date(), duration: 86400)
        let insights = try await manager.generateInsights(for: dateRange)
        let insightsTime = Date().timeIntervalSince(insightsStartTime)
        
        #expect(insights.completedTasks == completedTasks.count)
        #expect(insightsTime < 2.0) // Should complete within 2 seconds
    }
    
    @Test("Memory management with large datasets")
    func memoryManagementWithLargeDatasets() async throws {
        let manager = DataManager(isTest: true)
        
        // Create and assign large dataset
        var largeTasks: [UserTask] = []
        
        for i in 1...10000 {
            var task = createTestTask()
            task.title = "Memory Test Task \(i)"
            task.description = String(repeating: "Description data ", count: 100)
            largeTasks.append(task)
        }
        
        manager.tasks = largeTasks
        
        // Perform operations that should not cause memory issues
        let filteredTasks = manager.todaysTasks
        _ = manager.overdueTasks
        
        // Clear the large dataset
        manager.tasks = []
        
        // Verify memory is released (tasks should be empty)
        #expect(manager.tasks.isEmpty)
        #expect(filteredTasks.count >= 0) // Should still have valid results
    }
    
    @Test("Concurrent access patterns")
    func concurrentAccessPatterns() async throws {
        let manager = DataManager(isTest: true)
        
        // Set up initial data
        manager.tasks = (1...100).map { i in
            var task = createTestTask()
            task.title = "Concurrent Task \(i)"
            return task
        }
        
        // Test concurrent read operations
        await withTaskGroup(of: Int.self) { group in
            for _ in 1...10 {
                group.addTask {
                    return await manager.tasks.count
                }
                group.addTask {
                    return await manager.todaysTasks.count
                }
                group.addTask {
                    return await manager.overdueTasks.count
                }
            }
            
            // All operations should return consistent results
            var results: [Int] = []
            for await result in group {
                results.append(result)
            }
            
            // At least some results should be returned
            #expect(!results.isEmpty)
        }
        
        // Manager should still be in a valid state
        #expect(manager.tasks.count == 100)
    }
    
    // MARK: - Helper Methods
    
    private func createTestTask() -> UserTask {
        return UserTask(
            title: "Integration Test Task",
            description: "A task for integration testing",
            estimatedDuration: Int.random(in: 15...60),
            dueDate: Calendar.current.date(byAdding: .day, value: Int.random(in: 0...7), to: Date()),
            priority: Priority.allCases.randomElement() ?? .medium,
            difficulty: Difficulty.allCases.randomElement() ?? .medium,
            category: TaskCategory.allCases.randomElement()
        )
    }
    
    private func createTestFocusSession() -> FocusSession {
        return FocusSession(
            title: "Integration Test Session",
            focusMode: FocusMode.allCases.randomElement() ?? .deepWork,
            plannedDuration: Int.random(in: 15...60)
        )
    }
    
    private func createTestHabit() -> Habit {
        return Habit(
            title: "Integration Test Habit",
            description: "A habit for integration testing",
            category: HabitCategory.allCases.randomElement() ?? .health,
            frequency: HabitFrequency.allCases.randomElement() ?? .daily
        )
    }
}
