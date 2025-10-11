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
        self.authVM.getUser()
    }
    
    @State private var authVM = AuthVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authVM)
                .onAppear {
                    // Initialize data manager when user is authenticated
                    if let currentUser = authVM.currentUser {
                        let dataManager = FocusDataManager(userId: currentUser.id)
                        Task {
                            await dataManager.loadAllData()
                        }
                    }
                }
        }
    }
}
