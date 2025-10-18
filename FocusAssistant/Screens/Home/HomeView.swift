//
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthVM.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var authVM = authVM
        
        if let user = authVM.currentUser {

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
        .environment(AuthVM(currentUser: User.example))
}
