//
//  User.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import Foundation

struct User: Identifiable, Codable {
    
    let id: String
    let fullName: String
    let email: String
    var createdAt: Date = Date()
    
    // ADHD-specific user preferences
    var preferences: UserPreferences = UserPreferences()
    var timezone: String = TimeZone.current.identifier
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    
    var firstName: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            return components.givenName ?? ""
        }
        
        return ""
    }
}

// ADHD-specific user preferences
struct UserPreferences: Codable {
    var defaultFocusTime: Int = 25 // minutes
    var defaultBreakTime: Int = 5  // minutes
    var longBreakTime: Int = 15    // minutes
    var pomodorosUntilLongBreak: Int = 4
    
    // Notification preferences
    var enableNotifications: Bool = true
    var enableSoundAlerts: Bool = true
    var enableVibrationAlerts: Bool = true
    var reminderFrequency: Int = 15 // minutes before task due
    
    // Visual preferences for ADHD users
    var preferredTheme: String = "default"
    var enableHighContrast: Bool = false
    var enableReducedMotion: Bool = false
    var fontSize: FontSize = .medium
    
    // Focus preferences
    var enableDistractiveAppBlocking: Bool = false
    var preferredFocusModes: [FocusMode] = []
}

enum FontSize: String, Codable, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
}

enum FocusMode: String, Codable, CaseIterable {
    case deepWork = "deepWork"
    case creative = "creative"
    case learning = "learning"
    case routine = "routine"
}

extension User {
    static var example: User {
        User(id: NSUUID().uuidString, fullName: "Nana Sekyere", email: "nanasekyere@example.com")
    }
}
