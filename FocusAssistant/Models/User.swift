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

extension User {
    static var example: User {
        User(id: NSUUID().uuidString, fullName: "Nana Sekyere", email: "nanasekyere@example.com")
    }
}
