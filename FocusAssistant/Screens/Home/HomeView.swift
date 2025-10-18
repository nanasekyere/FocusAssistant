//
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

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
                    
                    Button("Focus History") {}
                    
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
