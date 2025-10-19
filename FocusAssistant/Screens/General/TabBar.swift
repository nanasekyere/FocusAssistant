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
    @Environment(DataManager.self) private var manager
    @State private var selectedTab: TabSelection = .home
    @State private var showAddTask: Bool = false
    
    var body: some View {
        if let user = manager.currentUser {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    NavigationStack {
                        HomeView()
                            .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                    }
                }
                
                Tab("Tasks", systemImage: "list.bullet.clipboard", value: .tasks) {
                    NavigationStack {
                        if manager.isLoading {
                            ProgressView()
                        } else {
                            TasksView()
                                .environment(manager)
                                .applyToolbar(firstName: user.firstName, showAddTask: $showAddTask)
                        }
                    }
                    .onAppear {
                        Task {
                            await manager.loadAllData()
                        }
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
            .sheet(isPresented: $showAddTask) {
                manager.checkCurrentUser()
            } content: {
                AddTaskView()
                    .environment(manager)
            }

        }
    }
}

#Preview {
    TabBar()
        .environment(DataManager(currentUser: User.example))
}
