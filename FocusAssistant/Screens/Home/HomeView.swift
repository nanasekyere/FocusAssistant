//
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI
import ButtonKit

struct HomeView: View {
    @Environment(DataManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var manager = manager
        
        if let user = manager.currentUser {

                VStack(spacing: 15) {
                    Button("Start Focus Session") {
                        
                    }
                    
                    Button("Add New Task") {}
                    
                    Button("View Tasks") {}
                    
                    Button("Set Daily Goals") {}
                    
                    Button("Focus Statistics") {}
                    
                    Button("Break Reminder Settings") {}
                    
                    AsyncButton("Test Alert") {
                        // Create a test task that will trigger an error
                        let testTask = UserTask(
                            title: "Test Error Task",
                            description: "This task is designed to trigger an error"
                        )
                        
                        // This will likely trigger a DataManagerError.notAuthenticated
                        // or operationFailed depending on the current state
                        // AsyncButton handles the async/throws automatically
                        try await manager.createTask(testTask)
                    }
                    
                    Button("Pomodoro Timer") {}
    
                }
                .navigationTitle("Staying focused, \(user.firstName)?")
            
            
        }
    }
}

#Preview {
    HomeView()
        .environment(DataManager(currentUser: User.example))
}
