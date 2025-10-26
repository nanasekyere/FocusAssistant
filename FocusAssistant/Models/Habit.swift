//
//  Habit.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Habit: Identifiable, Codable {
    @DocumentID var id: String?

    var title: String
    var description: String?
    var category: HabitCategory
    
    // Scheduling
    var frequency: HabitFrequency
    var targetDaysPerWeek: Int?
    var specificDays: Set<Weekday>?
    var preferredTime: String? // "09:00" format
    var duration: Int? // minutes
    
    // ADHD-friendly features
    var isFlexible: Bool = true // Allow completion within a time window
    var timeWindow: Int = 120 // minutes of flexibility
    var reminderOffset: Int = 15 // minutes before preferred time
    
    // Tracking
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalCompletions: Int = 0
    var isActive: Bool = true
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct HabitCompletion: Identifiable, Codable {
    var id: String = UUID().uuidString
    
    var completedAt: Date = Date()
    var mood: Mood?
    var energyLevel: EnergyLevel?
    var difficulty: Int? // 1-5 scale
    var notes: String?
    
    // Context
    var location: String?
    var weather: String?
    var completionMethod: CompletionMethod = .manual
}

enum HabitCategory: String, Codable, CaseIterable {
    case health = "health"
    case productivity = "productivity"
    case selfCare = "selfCare"
    case learning = "learning"
    case social = "social"
    case creative = "creative"
    case mindfulness = "mindfulness"
    case organization = "organization"
    
    var icon: String {
        switch self {
        case .health: return "heart"
        case .productivity: return "checkmark.circle"
        case .selfCare: return "leaf"
        case .learning: return "book"
        case .social: return "person.2"
        case .creative: return "paintbrush"
        case .mindfulness: return "brain.head.profile"
        case .organization: return "folder"
        }
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case custom = "custom"
    
    var description: String {
        switch self {
        case .daily: return "Every day"
        case .weekly: return "Weekly"
        case .custom: return "Custom schedule"
        }
    }
}

enum Weekday: String, Codable, CaseIterable {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    var calendarWeekday: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    static var today: Weekday? {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        return Weekday.allCases.first { $0.calendarWeekday == todayWeekday }
    }
}

enum CompletionMethod: String, Codable {
    case manual = "manual"
    case automatic = "automatic" // Through integrations
    case reminder = "reminder"   // Completed via reminder
}

// Extensions
extension Habit {
    var shouldShowToday: Bool {
        switch frequency {
        case .daily:
            return true
        case .weekly:
            return false // Handle weekly separately
        case .custom:
            guard let specificDays = specificDays,
                  let today = Weekday.today else { return false }
            return specificDays.contains(today)
        }
    }
    
    var completionRate: Double {
        let daysActive = Date().timeIntervalSince(createdAt)
        let expectedCompletions = Int(daysActive / (24 * 60 * 60)) // Days active
        guard expectedCompletions > 0 else { return 0 }
        return Double(totalCompletions) / Double(expectedCompletions)
    }
    
    static var example: Habit {
        Habit(
            title: "Morning meditation",
            description: "5 minutes of mindfulness to start the day",
            category: .mindfulness,
            frequency: .daily,
            preferredTime: "08:00",
            duration: 5
        )
    }
}
