//
//  FocusAssistantApp.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//

import SwiftUI
import SwiftData

@main
struct FocusAssistantApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserTask.self,
            BlendedTask.self,
            RepeatingTask.self,
            PomodoroTask.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Tabs()
        }
        .modelContainer(sharedModelContainer)
    }
}
