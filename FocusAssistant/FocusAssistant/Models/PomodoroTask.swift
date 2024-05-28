//
//  PomodoroTask.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//

import Foundation
import SwiftData
import UserNotifications

@Model class PomodoroTask: Task {
    var identity: UUID = UUID()
    var name: String = ""
    var duration: Int = 1500
    var priority: Priority = Priority.low
    var imageURL: String?
    var details: String?
    var isCompleted: Bool = false
    var timeStarted: Date?
    
    var pomodoroCounter: Int = 0
    var isBreak: Bool = false

    init(name: String, duration: Int, priority: Priority, imageURL: String? = nil, details: String? = nil) {
        self.name = name
        self.duration = duration
        self.priority = priority
        self.imageURL = imageURL
        self.details = details
    }

    func startTask() {
        timeStarted = Date.now
    }

    func scheduleNotification() {
        print("noti")
    }

    func descheduleNotification() {
        print("no noti")
    }

    func completeTask() {
        if isBreak {
            isBreak = false
            duration = 1500
            // Schedule next interval here
            return
        }

        pomodoroCounter += 1

        if pomodoroCounter == 4 {
            isCompleted = true
            pomodoroCounter = 0
        } else {
            isBreak = true
            duration = 300
        }
    }
}

var mockPomodoroTask = PomodoroTask(name: "Work on assignment", duration: 1500, priority: .medium, imageURL: "book.pages.fill", details: "Don't forget to save file after each change you make in the IDE")
