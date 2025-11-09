//
//  PreviewDataManager.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 01/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Preview Data
struct PreviewData {
    
    // MARK: - Sample Tasks
    static let sampleTasks: [UserTask] = [
        UserTask(
            id: "task-1",
            title: "Complete quarterly report",
            description: "Finish the Q4 productivity analysis and submit to management",
            isCompleted: false,
            estimatedDuration: 120,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            scheduledDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            priority: .high,
            difficulty: .hard,
            energyLevel: .high,
            category: .work,
            tags: ["report", "quarterly", "management"],
            subtasks: [
                Subtask(title: "Gather data from all departments", isCompleted: true, estimatedDuration: 30, order: 1),
                Subtask(title: "Analyze productivity metrics", isCompleted: false, estimatedDuration: 45, order: 2),
                Subtask(title: "Create visualizations", isCompleted: false, estimatedDuration: 30, order: 3),
                Subtask(title: "Write executive summary", isCompleted: false, estimatedDuration: 15, order: 4)
            ],
            location: "Office",
            requiredTools: ["Excel", "PowerPoint", "Company database"],
            bestTimeOfDay: .morning,
            postponementCount: 2,
            lastPostponedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            postponementReason: "Waiting for data from finance team"
        ),
        
        UserTask(
            id: "task-2",
            title: "Grocery shopping",
            description: "Weekly grocery run - don't forget the essentials",
            isCompleted: true,
            estimatedDuration: 45,
            scheduledDate: Date(),
            priority: .medium,
            difficulty: .easy,
            energyLevel: .medium,
            category: .personal,
            tags: ["groceries", "weekly", "essentials"],
            subtasks: [
                Subtask(title: "Check pantry and fridge", isCompleted: true, estimatedDuration: 5, order: 1),
                Subtask(title: "Make shopping list", isCompleted: true, estimatedDuration: 10, order: 2),
                Subtask(title: "Go to store", isCompleted: false, estimatedDuration: 30, order: 3)
            ],
            location: "Supermarket",
            requiredTools: ["Shopping list", "Reusable bags", "Payment card"],
            bestTimeOfDay: .afternoon
        ),
        
        UserTask(
            id: "task-3",
            title: "Read 30 minutes",
            description: "Continue reading 'Atomic Habits' for personal development",
            isCompleted: true,
            estimatedDuration: 30,
            actualDuration: 35,
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            completedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            priority: .medium,
            difficulty: .easy,
            energyLevel: .low,
            category: .learning,
            tags: ["reading", "habits", "self-improvement"],
            location: "Living room",
            bestTimeOfDay: .evening
        ),
        
        UserTask(
            id: "task-4",
            title: "Exercise - 30 min cardio",
            description: "Daily cardio workout to maintain fitness",
            isCompleted: false,
            estimatedDuration: 30,
            scheduledDate: Date(),
            priority: .medium,
            difficulty: .medium,
            energyLevel: .high,
            category: .health,
            tags: ["exercise", "cardio", "daily"],
            location: "Gym",
            requiredTools: ["Workout clothes", "Water bottle", "Headphones"],
            bestTimeOfDay: .morning
        ),
        
        UserTask(
            id: "task-5",
            title: "Call mom",
            description: "Weekly check-in call with family",
            isCompleted: false,
            estimatedDuration: 20,
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            priority: .high,
            difficulty: .easy,
            energyLevel: .low,
            category: .social,
            tags: ["family", "weekly", "important"],
            bestTimeOfDay: .evening
        )
    ]
    
    // MARK: - Sample Focus Sessions
    static let sampleFocusSessions: [FocusSession] = [
        FocusSession(
            id: "session-1",
            taskId: "task-1",
            title: "Deep work on quarterly report",
            focusMode: .deepWork,
            plannedDuration: 90,
            actualDuration: 85,
            startTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            endTime: Calendar.current.date(byAdding: .minute, value: -35, to: Date()),
            status: .completed,
            pauseCount: 1,
            totalPauseTime: 300, // 5 minutes
            distractions: [
                Distraction(
                    type: .phone,
                    description: "Checked notification",
                    timestamp: Calendar.current.date(byAdding: .minute, value: -90, to: Date()) ?? Date(),
                    duration: 120,
                    severity: .minor
                ),
                Distraction(
                    type: .thoughts,
                    description: "Worried about deadline",
                    timestamp: Calendar.current.date(byAdding: .minute, value: -60, to: Date()) ?? Date(),
                    duration: 180,
                    severity: .moderate
                )
            ],
            moodBefore: .focused,
            moodAfter: .tired,
            energyBefore: .high,
            energyAfter: .medium,
            location: "Home office",
            noiseLevel: .quiet,
            breaks: [
                BreakSession(
                    type: .short,
                    duration: 5,
                    startTime: Calendar.current.date(byAdding: .minute, value: -95, to: Date()) ?? Date(),
                    endTime: Calendar.current.date(byAdding: .minute, value: -90, to: Date()),
                    activities: ["Stretch", "Water"]
                )
            ],
            productivityRating: 4,
            focusRating: 3,
            notes: "Good session overall, but had some distracting thoughts about the deadline"
        ),
        
        FocusSession(
            id: "session-2",
            taskId: "task-3",
            title: "Reading session",
            focusMode: .learning,
            plannedDuration: 30,
            actualDuration: 35,
            startTime: Calendar.current.date(byAdding: .hour, value: -24, to: Date()),
            endTime: Calendar.current.date(byAdding: .minute, value: -1405, to: Date()),
            status: .completed,
            pauseCount: 0,
            totalPauseTime: 0,
            moodBefore: .calm,
            moodAfter: .excited,
            energyBefore: .medium,
            energyAfter: .medium,
            location: "Living room",
            noiseLevel: .silent,
            productivityRating: 5,
            focusRating: 5,
            notes: "Excellent reading session! Really absorbed the content about habit stacking."
        ),
        
        FocusSession(
            id: "session-3",
            taskId: nil,
            title: "Morning planning session",
            focusMode: .planning,
            plannedDuration: 25,
            actualDuration: nil,
            startTime: Date(),
            status: .active,
            pauseCount: 0,
            totalPauseTime: 0,
            moodBefore: .neutral,
            energyBefore: .medium,
            location: "Kitchen table",
            noiseLevel: .moderate
        )
    ]
    
    // MARK: - Sample Habits
    static let sampleHabits: [Habit] = [
        Habit(
            id: "habit-1",
            title: "Morning meditation",
            description: "5 minutes of mindfulness meditation to start the day right",
            category: .mindfulness,
            frequency: .daily,
            preferredTime: "07:00",
            duration: 5,
            isFlexible: true,
            timeWindow: 60,
            reminderOffset: 10,
            currentStreak: 12,
            longestStreak: 28,
            totalCompletions: 89,
            createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        ),
        
        Habit(
            id: "habit-2",
            title: "Drink water",
            description: "Drink a full glass of water every 2 hours",
            category: .health,
            frequency: .custom,
            specificDays: Set([.monday, .tuesday, .wednesday, .thursday, .friday]),
            duration: 1,
            isFlexible: true,
            timeWindow: 30,
            reminderOffset: 5,
            currentStreak: 5,
            longestStreak: 15,
            totalCompletions: 156,
            createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        ),
        
        Habit(
            id: "habit-3",
            title: "Review daily goals",
            description: "Spend 10 minutes reviewing and adjusting daily goals",
            category: .productivity,
            frequency: .daily,
            preferredTime: "08:30",
            duration: 10,
            isFlexible: true,
            timeWindow: 90,
            reminderOffset: 15,
            currentStreak: 7,
            longestStreak: 21,
            totalCompletions: 45,
            createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        ),
        
        Habit(
            id: "habit-4",
            title: "Evening walk",
            description: "Take a 15-minute walk to decompress after work",
            category: .health,
            frequency: .weekly,
            targetDaysPerWeek: 5,
            specificDays: Set([.monday, .tuesday, .wednesday, .thursday, .friday]),
            preferredTime: "18:00",
            duration: 15,
            isFlexible: true,
            timeWindow: 120,
            reminderOffset: 20,
            currentStreak: 3,
            longestStreak: 8,
            totalCompletions: 23,
            createdAt: Calendar.current.date(byAdding: .weekOfYear, value: -6, to: Date()) ?? Date()
        ),
        
        Habit(
            id: "habit-5",
            title: "Clean workspace",
            description: "Tidy up desk and organize materials",
            category: .organization,
            frequency: .weekly,
            targetDaysPerWeek: 2,
            specificDays: Set([.wednesday, .friday]),
            preferredTime: "17:30",
            duration: 10,
            isFlexible: false,
            timeWindow: 30,
            reminderOffset: 10,
            currentStreak: 0,
            longestStreak: 4,
            totalCompletions: 12,
            isActive: true,
            createdAt: Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date()) ?? Date()
        )
    ]
    
    // MARK: - Sample Reminders
    static let sampleReminders: [Reminder] = [
        Reminder(
            id: "reminder-1",
            title: "Take vitamin D",
            message: "Don't forget your daily vitamin D supplement",
            triggerDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date(),
            isRepeating: true,
            type: .medication,
            urgency: .normal,
            estimatedDuration: 1,
            repeatInterval: .daily,
            taskId: nil,
            habitId: nil,
            snoozeCount: 0
        ),
        
        Reminder(
            id: "reminder-2",
            title: "Team standup meeting",
            message: "Daily standup in conference room B",
            triggerDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
            type: .appointment,
            urgency: .high,
            context: ReminderContext(
                location: "Conference room B",
                requiredItems: ["Notebook", "Laptop"],
                preparationTime: 5,
                energyLevelNeeded: .medium
            ),
            estimatedDuration: 30
        ),
        
        Reminder(
            id: "reminder-3",
            title: "Start focus session",
            message: "Time to begin your planned deep work session",
            triggerDate: Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date(),
            type: .focusSession,
            urgency: .normal,
            estimatedDuration: 90, focusSessionId: "session-3"
        ),
        
        Reminder(
            id: "reminder-4",
            title: "Take a break",
            message: "You've been working for 90 minutes. Time for a break!",
            triggerDate: Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date(),
            isCompleted: true,
            type: .rest,
            urgency: .normal,
            estimatedDuration: 15,
            lastTriggered: Calendar.current.date(byAdding: .minute, value: -5, to: Date())
        ),
        
        Reminder(
            id: "reminder-5",
            title: "Call dentist",
            message: "Schedule 6-month cleaning appointment",
            triggerDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            type: .custom,
            urgency: .low,
            context: ReminderContext(
                requiredItems: ["Phone", "Calendar"],
                preparationTime: 2,
                energyLevelNeeded: .low
            ),
            estimatedDuration: 10,
            snoozeCount: 2,
            lastSnoozedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())
        )
    ]
    
    // MARK: - Sample Insights
    static let sampleInsights: UserInsights = {
        let dateRange = DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            end: Date()
        )
        
        var insights = UserInsights(dateRange: dateRange)
        
        // Productivity insights
        insights.totalFocusTime = 420 // 7 hours over the week
        insights.averageSessionLength = 52.5 // minutes
        insights.completedTasks = 15
        insights.completedHabits = 28
        
        // ADHD-specific insights
        insights.mostProductiveTimeOfDay = .morning
        insights.averageDistractionCount = 3.2
        insights.mostCommonDistractionType = .phone
        insights.bestPerformingFocusMode = .deepWork
        
        // Patterns
        insights.streakData = StreakData(
            currentTaskStreak: 5,
            longestTaskStreak: 12,
            currentHabitStreaks: [
                "habit-1": 12,
                "habit-2": 5,
                "habit-3": 7
            ],
            longestHabitStreaks: [
                "habit-1": 28,
                "habit-2": 15,
                "habit-3": 21
            ]
        )
        
        insights.moodPatterns = [
            .focused: 8,
            .calm: 5,
            .excited: 3,
            .tired: 4,
            .neutral: 2
        ]
        
        insights.energyPatterns = [
            .high: 6,
            .medium: 12,
            .low: 4
        ]
        
        return insights
    }()
    
    // MARK: - Helper Methods
    
    /// Generates additional sample tasks for testing
    static func generateMoreTasks(count: Int) -> [UserTask] {
        let taskTitles = [
            "Update LinkedIn profile",
            "Organize photos",
            "Research vacation destinations",
            "Clean out email inbox",
            "Update budget spreadsheet",
            "Call insurance company",
            "Schedule car maintenance",
            "Write blog post",
            "Practice Spanish",
            "Meal prep for the week"
        ]
        
        let categories: [TaskCategory] = [.work, .personal, .health, .learning, .creative, .admin, .social, .maintenance]
        let priorities: [Priority] = [.urgent, .high, .medium, .low]
        let difficulties: [Difficulty] = [.easy, .medium, .hard, .overwhelming]
        
        return (0..<count).map { index in
            let title = taskTitles[index % taskTitles.count]
            return UserTask(
                id: "generated-task-\(index)",
                title: title,
                estimatedDuration: Int.random(in: 15...120),
                dueDate: Calendar.current.date(byAdding: .day, value: Int.random(in: -2...7), to: Date()),
                priority: priorities.randomElement() ?? .medium,
                difficulty: difficulties.randomElement() ?? .medium,
                energyLevel: EnergyLevel.allCases.randomElement() ?? .medium,
                category: categories.randomElement()
            )
        }
    }
}

struct CustomPreviewTrait: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        @Previewable @State var manager = DataManager(isTest: true)
        return content
            .fontDesign(.rounded)
            .environment(manager)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static let previewData: Self = .modifier(CustomPreviewTrait())
}
