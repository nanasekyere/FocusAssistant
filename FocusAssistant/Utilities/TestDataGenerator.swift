//
//  TestDataGenerator.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//
// Used to create test data and populate Firestore Database

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct TestDataGenerator {
    
    static func generateAllTestData(for userId: String) {
        let db = Firestore.firestore()
        
        generateTasks(db: db, userId: userId)
        generateFocusSessions(db: db, userId: userId)
        generateHabits(db: db, userId: userId)
        generateHabitCompletions(db: db, userId: userId)
        generateReminders(db: db, userId: userId)
        generateDailyStats(db: db, userId: userId)
        generateInsights(db: db, userId: userId)
    }

    private static func generateTasks(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("tasks")
        for i in 1...5 {
            let task = UserTask(
                title: "Task \(i)",
                description: "This is task number \(i)",
                isCompleted: Bool.random(),
                estimatedDuration: Int.random(in: 30...90),
                actualDuration: nil,
                dueDate: Date().addingTimeInterval(Double.random(in: 0...86400)),
                scheduledDate: nil,
                completedAt: nil,
                priority: .medium,
                difficulty: .medium,
                energyLevel: .medium,
                category: nil,
                tags: ["test"],
                subtasks: [],
                isBreakdownComplete: false,
                location: nil,
                requiredTools: [],
                bestTimeOfDay: .morning,
                createdAt: Date(),
                updatedAt: Date(),
                focusSessions: [],
                postponementCount: 0,
                lastPostponedAt: nil,
                postponementReason: nil
            )
            try? ref.addDocument(from: task)
        }
    }

    private static func generateFocusSessions(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("focusSessions")
        for i in 1...3 {
            let session = FocusSession(
                id: nil,
                taskId: nil,
                title: "Focus Session \(i)",
                focusMode: .deepWork,
                plannedDuration: 50,
                actualDuration: nil,
                startTime: nil,
                endTime: nil,
                status: .planned,
                pauseCount: 0,
                totalPauseTime: 0,
                distractions: [],
                moodBefore: .focused,
                moodAfter: nil,
                energyBefore: .medium,
                energyAfter: nil,
                location: nil,
                noiseLevel: nil,
                ambientConditions: nil,
                breaks: [],
                productivityRating: nil,
                focusRating: nil,
                notes: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            try? ref.addDocument(from: session)
        }
    }

    private static func generateHabits(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("habits")
        for i in 1...3 {
            let habit = Habit(
                id: nil,
                title: "Habit \(i)",
                description: "Habit description \(i)",
                category: .health,
                frequency: .daily,
                targetDaysPerWeek: nil,
                specificDays: nil,
                preferredTime: nil,
                duration: 15,
                isFlexible: true,
                timeWindow: 60,
                reminderOffset: 10,
                currentStreak: 5,
                longestStreak: 10,
                totalCompletions: 20,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            )
            try? ref.addDocument(from: habit)
        }
    }

    private static func generateHabitCompletions(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("habitCompletions")
        for i in 1...3 {
            let completion = HabitCompletion(
                completedAt: Date(),
                mood: .calm,
                energyLevel: .high,
                difficulty: 2,
                notes: "Felt good",
                location: "Home",
                weather: "Sunny",
                completionMethod: .manual
            )
            try? ref.addDocument(from: completion)
        }
    }

    private static func generateReminders(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("reminders")
        for i in 1...3 {
            let reminder = Reminder(
                id: nil,
                title: "Reminder \(i)",
                message: "Don't forget this!",
                triggerDate: Date().addingTimeInterval(3600),
                isCompleted: false,
                isRepeating: false,
                type: .task,
                urgency: .normal,
                context: nil,
                estimatedDuration: nil,
                repeatInterval: nil,
                endDate: nil,
                maxRepetitions: nil,
                completedRepetitions: 0,
                taskId: nil,
                habitId: nil,
                focusSessionId: nil,
                lastTriggered: nil,
                snoozeCount: 0,
                lastSnoozedAt: nil,
                dismissedWithoutAction: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            try? ref.addDocument(from: reminder)
        }
    }

    private static func generateDailyStats(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("dailyStats")
        for i in 1...3 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let docId = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
            
            let stats = DailyStats(
                date: date,
                focusTime: Int.random(in: 60...180),
                completedTasks: Int.random(in: 1...5),
                completedHabits: Int.random(in: 1...5),
                distractionCount: Int.random(in: 0...3),
                averageMood: Double.random(in: 1...5),
                averageEnergy: Double.random(in: 1...5),
                notes: "Good day overall.",
            )
            try? ref.document(docId).setData(from: stats)
        }
    }

    private static func generateInsights(db: Firestore, userId: String) {
        let ref = db.collection("users").document(userId).collection("insights")
        let insight = UserInsights(
            dateRange: DateInterval(start: Date().addingTimeInterval(-604800), end: Date()),
            totalFocusTime: 600,
            averageSessionLength: 50.0,
            completedTasks: 12,
            completedHabits: 10,
            mostProductiveTimeOfDay: .morning,
            averageDistractionCount: 2.5,
            mostCommonDistractionType: .phone,
            bestPerformingFocusMode: .routine,
            streakData: StreakData(),
            moodPatterns: [.excited: 5, .neutral: 3],
            energyPatterns: [.high: 4, .medium: 3],
            generatedAt: Date()
        )
        try? ref.addDocument(from: insight)
    }
}
