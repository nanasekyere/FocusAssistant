//
//  ContentView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(SignInVM.self) private var authVM
    
    var body: some View {
        Group {
            if authVM.userSession != nil {
                ProfileView()
            } else {
                SignInView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(SignInVM())
}
