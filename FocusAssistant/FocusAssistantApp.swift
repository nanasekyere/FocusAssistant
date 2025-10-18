//
//  FocusAssistantApp.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct FocusAssistantApp: App {
    
    init() {
        FirebaseApp.configure()
        self.dataManager.start()
    }
    
    @State private var dataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataManager)
        }
    }
}
