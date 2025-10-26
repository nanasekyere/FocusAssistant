//
//  FocusSession.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

struct FocusSession: Identifiable, Codable {
    @DocumentID var id: String?
    
    var taskId: String? // Optional - can be a general focus session
    var title: String
    var focusMode: FocusMode
    
    // Session timing
    var plannedDuration: Int // minutes
    var actualDuration: Int? // minutes actually spent
    var startTime: Date?
    var endTime: Date?
    
    // Session state
    var status: SessionStatus = .planned
    var pauseCount: Int = 0
    var totalPauseTime: Int = 0 // seconds
    
    // ADHD-specific tracking
    var distractions: [Distraction] = []
    var moodBefore: Mood?
    var moodAfter: Mood?
    var energyBefore: EnergyLevel?
    var energyAfter: EnergyLevel?
    
    // Environment
    var location: String?
    var noiseLevel: NoiseLevel?
    var ambientConditions: String?
    
    // Break sessions
    var breaks: [BreakSession] = []
    
    // Ratings and notes
    var productivityRating: Int? // 1-5 scale
    var focusRating: Int? // 1-5 scale
    var notes: String?
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct BreakSession: Codable {
    var type: BreakType
    var duration: Int // minutes
    var startTime: Date
    var endTime: Date?
    var activities: [String] = [] // What did during break
}

struct Distraction: Codable {
    var type: DistractionType
    var description: String?
    var timestamp: Date = Date()
    var duration: Int? // seconds if measurable
    var severity: DistactionSeverity
}

enum SessionStatus: String, Codable, CaseIterable {
    case planned = "planned"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
}

enum BreakType: String, Codable, CaseIterable {
    case short = "short"           // 5 minutes
    case medium = "medium"         // 15 minutes
    case long = "long"            // 30+ minutes
    case unplanned = "unplanned"  // Unexpected break
}

enum DistractionType: String, Codable, CaseIterable {
    case phone = "phone"
    case socialMedia = "socialMedia"
    case email = "email"
    case people = "people"
    case noise = "noise"
    case thoughts = "thoughts"
    case physical = "physical"     // hunger, bathroom, etc.
    case other = "other"
}

enum DistactionSeverity: String, Codable, CaseIterable {
    case minor = "minor"      // Quick glance, easily refocused
    case moderate = "moderate" // Short interruption, took time to refocus
    case major = "major"      // Significant interruption, hard to return to task
}

enum Mood: String, Codable, CaseIterable {
    case excited = "excited"
    case focused = "focused"
    case calm = "calm"
    case neutral = "neutral"
    case tired = "tired"
    case anxious = "anxious"
    case frustrated = "frustrated"
    case overwhelmed = "overwhelmed"
    
    var emoji: String {
        switch self {
        case .excited: return "😄"
        case .focused: return "🎯"
        case .calm: return "😌"
        case .neutral: return "😐"
        case .tired: return "😴"
        case .anxious: return "😰"
        case .frustrated: return "😤"
        case .overwhelmed: return "😵‍💫"
        }
    }
}

enum NoiseLevel: String, Codable, CaseIterable {
    case silent = "silent"
    case quiet = "quiet"
    case moderate = "moderate"
    case loud = "loud"
    case veryLoud = "veryLoud"
}

enum FocusMode: String, Codable, CaseIterable {
    case deepWork = "deepWork"
    case creative = "creative"
    case learning = "learning"
    case routine = "routine"
    case planning = "planning"
    case communication = "communication"
    case research = "research"
    case maintenance = "maintenance"
    
    var description: String {
        switch self {
        case .deepWork: return "Deep Work"
        case .creative: return "Creative Work"
        case .learning: return "Learning"
        case .routine: return "Routine Tasks"
        case .planning: return "Planning"
        case .communication: return "Communication"
        case .research: return "Research"
        case .maintenance: return "Maintenance"
        }
    }
    
    var icon: String {
        switch self {
        case .deepWork: return "brain.head.profile"
        case .creative: return "paintbrush"
        case .learning: return "book"
        case .routine: return "list.bullet"
        case .planning: return "calendar"
        case .communication: return "message"
        case .research: return "magnifyingglass"
        case .maintenance: return "wrench"
        }
    }
    
    var suggestedDuration: Int {
        switch self {
        case .deepWork: return 90 // 90 minutes for deep work
        case .creative: return 120 // 2 hours for creative work
        case .learning: return 50 // 50 minutes for learning
        case .routine: return 25 // 25 minutes for routine tasks
        case .planning: return 30 // 30 minutes for planning
        case .communication: return 15 // 15 minutes for communication
        case .research: return 60 // 60 minutes for research
        case .maintenance: return 20 // 20 minutes for maintenance
        }
    }
}


// Extensions for focus session management
extension FocusSession {
    var isActive: Bool {
        return status == .active
    }
    
    var isPaused: Bool {
        return status == .paused
    }
    
    var isCompleted: Bool {
        return status == .completed
    }
    
    var efficiency: Double {
        guard let actualDuration = actualDuration, actualDuration > 0 else { return 0 }
        let focusTime = actualDuration - (totalPauseTime / 60) // Convert pause time to minutes
        if focusTime < 0 { return 0 }
        return Double(focusTime) / Double(actualDuration)
    }
    
    var totalDistractionTime: Int {
        return distractions.compactMap { $0.duration }.reduce(0, +)
    }
    
    static var example: FocusSession {
        FocusSession(
            taskId: "task456",
            title: "Work on presentation",
            focusMode: .deepWork,
            plannedDuration: 25,
            moodBefore: .focused,
            energyBefore: .high
        )
    }
}
