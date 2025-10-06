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
    
    @State private var signInVM = SignInVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(signInVM)
        }
    }
}
