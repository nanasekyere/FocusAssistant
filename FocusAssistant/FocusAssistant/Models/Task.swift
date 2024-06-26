//
//  TaskProtocol.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//

import Foundation

protocol Task {
    var identity: UUID { get }
    var name: String { get set }
    var duration: Int { get set }
    var priority: Priority { get set }
    var imageURL: String? { get set }
    var details: String? { get set }
    var isCompleted: Bool { get set }
    var timeStarted: Date? { get set }

    func scheduleNotification()
    func descheduleNotification()
    func startTask()
    func completeTask()
}

enum Priority: String, CaseIterable, Codable {
    case low, medium, high
}
