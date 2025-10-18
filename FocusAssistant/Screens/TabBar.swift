//
//  TabBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

enum TabSelection {
    case home
    case tasks
    case sessions
    case habits
    case insights
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
                
                Tab("Tasks", systemImage: "list.bullet.clipboard", value: .tasks) {
                    NavigationStack {
                        Text("Today")
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
                
                Tab("Sessions", systemImage: "brain", value: .sessions) {
                    NavigationStack {
                        ProfileView()
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
                
                Tab("Habits", systemImage: "repeat.circle.fill", value: .habits) {
                    NavigationStack {
                        ProfileView()
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
                
                Tab("Insights", systemImage: "chart.bar.fill", value: .insights) {
                    NavigationStack {
                        ProfileView()
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
            
            }
        }
    }
}

#Preview {
    TabBar()
        .environment(AuthVM(currentUser: User.example))
}
