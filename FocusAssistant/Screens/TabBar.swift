//
//  TabBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

enum TabSelection {
    case home
    case today
    case analytics
}

struct TabBar: View {
    @Environment(AuthVM.self) private var authVM
    @State private var selectedTab: TabSelection = .home
    @State private var showAddTask: Bool = false
    
    var body: some View {
        if let user = authVM.currentUser {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    NavigationStack {
                        HomeView()
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
                
                Tab("Today", systemImage: "calendar", value: .today) {
                    NavigationStack {
                        Text("Today")
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
                
                Tab("Analytics", systemImage: "chart.bar.fill", value: .analytics) {
                    ProfileView()
                }
            }
        }
    }
}

#Preview {
    TabBar()
        .environment(AuthVM(currentUser: User.example))
}
