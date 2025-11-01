//
//  Reminder.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Reminder: Identifiable, Codable, FirestoreModel {
    @DocumentID var id: String?
    
    var title: String
    var message: String?
    var triggerDate: Date
    var isCompleted: Bool = false
    var isRepeating: Bool = false
    
    // ADHD-specific features
    var type: ReminderType
    var urgency: ReminderUrgency = .normal
    var context: ReminderContext?
    var estimatedDuration: Int? // minutes
    
    // Repetition settings
    var repeatInterval: RepeatInterval?
    var endDate: Date?
    var maxRepetitions: Int?
    var completedRepetitions: Int = 0
    
    // Associated entities
    var taskId: String?
    var habitId: String?
    var focusSessionId: String?
    
    // Interaction tracking
    var lastTriggered: Date?
    var snoozeCount: Int = 0
    var lastSnoozedAt: Date?
    var dismissedWithoutAction: Bool = false
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct ReminderContext: Codable {
    var location: String?
    var requiredItems: [String] = []
    var preparationTime: Int? // minutes needed to prepare
    var energyLevelNeeded: EnergyLevel?
}

enum ReminderType: String, Codable, CaseIterable {
    case task = "task"                    // Task deadline approaching
    case habit = "habit"                  // Time for habit
    case rest = "rest"                  // Time for a break / rest
    case medication = "medication"        // Medicine reminder
    case appointment = "appointment"      // Meeting/appointment
    case deadline = "deadline"           // Important deadline
    case focusSession = "focusSession"   // Start focus session
    case transition = "transition"       // Transition between activities
    case selfCare = "selfCare"          // Self-care activities
    case custom = "custom"               // User-defined
    
    var icon: String {
        switch self {
        case .task: return "checkmark.circle"
        case .habit: return "repeat"
        case .rest: return "pause.circle"
        case .medication: return "pills"
        case .appointment: return "calendar"
        case .deadline: return "exclamationmark.triangle"
        case .focusSession: return "brain.head.profile"
        case .transition: return "arrow.right.circle"
        case .selfCare: return "heart"
        case .custom: return "bell"
        }
    }
}

enum ReminderUrgency: String, Codable, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case critical = "critical"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .normal: return "blue"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

enum RepeatInterval: String, Codable, CaseIterable {
    case minutes15 = "15minutes"
    case minutes30 = "30minutes"
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"
    
    var description: String {
        switch self {
        case .minutes15: return "Every 15 minutes"
        case .minutes30: return "Every 30 minutes"
        case .hourly: return "Every hour"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom: return "Custom"
        }
    }
}

// Extensions
extension Reminder {
    var isOverdue: Bool {
        return !isCompleted && triggerDate < Date()
    }
    
    var isDueToday: Bool {
        return Calendar.current.isDateInToday(triggerDate)
    }
    
    var timeUntilDue: TimeInterval {
        return triggerDate.timeIntervalSinceNow
    }
    
    var shouldRepeat: Bool {
        return isRepeating && 
               (maxRepetitions == nil || completedRepetitions < maxRepetitions!) &&
               (endDate == nil || Date() < endDate!)
    }
    
    static var example: Reminder {
        Reminder(
            title: "Take medication",
            message: "Don't forget your morning medication",
            triggerDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
            isRepeating: true, type: .medication,
            urgency: .high,
            repeatInterval: .daily
        )
    }
}

// MARK: - Analytics and Insights Models

struct UserInsights: Codable {
    let dateRange: DateInterval
    
    // Productivity insights
    var totalFocusTime: Int = 0 // minutes
    var averageSessionLength: Double = 0
    var completedTasks: Int = 0
    var completedHabits: Int = 0
    
    // ADHD-specific insights
    var mostProductiveTimeOfDay: TimeOfDay?
    var averageDistractionCount: Double = 0
    var mostCommonDistractionType: DistractionType?
    var bestPerformingFocusMode: FocusMode?
    
    // Patterns
    var streakData: StreakData = StreakData()
    var moodPatterns: [Mood: Int] = [:]
    var energyPatterns: [EnergyLevel: Int] = [:]
    
    var generatedAt: Date = Date()
}

struct StreakData: Codable {
    var currentTaskStreak: Int = 0
    var longestTaskStreak: Int = 0
    var currentHabitStreaks: [String: Int] = [:] // habitId: streak
    var longestHabitStreaks: [String: Int] = [:] // habitId: longest streak
}

struct DailyStats: Codable {
    let date: Date
    
    var focusTime: Int = 0 // minutes
    var completedTasks: Int = 0
    var completedHabits: Int = 0
    var distractionCount: Int = 0
    var averageMood: Double?
    var averageEnergy: Double?
    var notes: String?
}
