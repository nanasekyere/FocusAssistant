//
//  RepeatingTask.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//

import Foundation
import SwiftData
import UserNotifications

@Model class RepeatingTask: TaskProtocol {
    var identity: UUID = UUID()
    var name: String = ""
    var duration: Int = 0
    var startTime: Date = Date()
    var priority: Priority = Priority.low
    var imageURL: String?
    var details: String?
    var isCompleted: Bool = false
    var isExpired: Bool = false

    var repeatEvery: Int

    init(name: String, duration: Int, startTime: Date, priority: Priority, imageURL: String? = nil, details: String? = nil, repeatEvery: Int) {
        self.name = name
        self.duration = duration
        self.startTime = startTime
        self.priority = priority
        self.imageURL = imageURL
        self.details = details
        self.repeatEvery = repeatEvery
    }

    // Function to schedule a notification for the task
    func scheduleNotification() {
        guard startTime > Date() else { return }

        if self.priority == .high {
            scheduleHighPriorityNotification() // Schedule high priority notification if applicable
        }

        let timeDifference = startTime.timeIntervalSinceNow
        guard timeDifference >= 300 else {
            // If the start time is less than 5 minutes away, don't schedule the notification
            return
        }

        let notificationTime = startTime.addingTimeInterval(-300) // 5 minutes before start time
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Your task \(self.name) is starting in 5 minutes!"
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationTime.timeIntervalSinceNow, repeats: false)

        let request = UNNotificationRequest(identifier: self.identity.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for task \(self.name) at \(notificationTime.formatted(date: .omitted, time: .shortened))")
            }
        }
    }

    // Function to schedule an immediate notification for high priority tasks
    func scheduleHighPriorityNotification() {
        guard self.priority == .high, startTime > Date() else { return }

        let notificationTime = startTime
        let content = UNMutableNotificationContent()
        content.title = "Task Starting"
        content.body = "Your task \(self.name) is starting now!"
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationTime.timeIntervalSinceNow, repeats: false)

        let request = UNNotificationRequest(identifier: self.identity.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for task \(self.name) at \(notificationTime.formatted(date: .omitted, time: .shortened))")
            }
        }
    }

    // Function to deschedule a notification for the task
    func descheduleNotification() {
        let notificationCenter = UNUserNotificationCenter.current()

        // Remove the notification request associated with the task ID
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.identity.uuidString])
    }

    // Function to complete the task
    func completeTask() {
        self.startTime = Date(timeInterval: TimeInterval(repeatEvery), since: startTime)
    }

    func endTask() {
        self.isCompleted = true
    }


}
