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
