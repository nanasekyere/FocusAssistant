//
//  Task.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct UserTask: Identifiable, Codable, FirestoreModel {
    @DocumentID var id: String?
    
    var title: String
    var description: String?
    var isCompleted: Bool = false
    
    // Time management
    var estimatedDuration: Int? // minutes
    var actualDuration: Int? // minutes tracked
    var dueDate: Date?
    var scheduledDate: Date?
    var completedAt: Date?
    
    // ADHD-specific features
    var priority: Priority = .medium
    var difficulty: Difficulty = .medium
    var energyLevel: EnergyLevel = .medium
    var category: TaskCategory?
    var tags: [String] = []
    
    // Break down for ADHD users
    var subtasks: [Subtask] = []
    var isBreakdownComplete: Bool = false
    
    // Context and environment
    var location: String?
    var requiredTools: [String] = []
    var bestTimeOfDay: TimeOfDay?
    
    // Tracking
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var focusSessions: [String] = [] // Reference to focus session IDs
    
    // Postponement tracking (important for ADHD users)
    var postponementCount: Int = 0
    var lastPostponedAt: Date?
    var postponementReason: String?
}

struct Subtask: Codable {
    var title: String
    var isCompleted: Bool = false
    var estimatedDuration: Int? // minutes
    var order: Int
}

enum Priority: String, Codable, CaseIterable {
    case urgent = "urgent"
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var color: Color {
        switch self {
        case .urgent: return Color.urgentPriority
        case .high: return Color.highPriority
        case .medium: return Color.mediumPriority
        case .low: return Color.lowPriority
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case overwhelming = "overwhelming"
    
    var emoji: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🟠"
        case .overwhelming: return "🔴"
        }
    }
}

enum EnergyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var description: String {
        switch self {
        case .low: return "Low energy needed"
        case .medium: return "Medium energy needed"
        case .high: return "High energy needed"
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case work = "work"
    case personal = "personal"
    case health = "health"
    case learning = "learning"
    case creative = "creative"
    case admin = "admin"
    case social = "social"
    case maintenance = "maintenance"
}

enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    case anytime = "anytime"
}

// Extension for task management
extension UserTask {
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var isDueTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }
    
    var completionPercentage: Double {
        guard !subtasks.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }
    
    static var example: UserTask {
        UserTask(
            title: "Complete project presentation",
            description: "Prepare slides for quarterly review",
            estimatedDuration: 120,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            priority: .high,
            difficulty: .medium,
            category: .work,
            tags: ["presentation", "quarterly", "important"]
        )
    }
}
