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
        self.signInVM.getUser()
    }
    
    @State private var signInVM = AuthVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(signInVM)
                .onAppear {
                    // Initialize data manager when user is authenticated
                    if let currentUser = signInVM.currentUser {
                        let dataManager = FocusDataManager(userId: currentUser.id)
                        Task {
                            await dataManager.loadAllData()
                        }
                    }
                }
        }
    }
}
