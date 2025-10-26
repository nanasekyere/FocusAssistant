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

struct TabContentView<Content: View>: View {
    let content: Content
    @Environment(DataManager.self) private var manager
    @Binding var showAddTask: Bool
    let firstName: String
    
    init(firstName: String, showAddTask: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.firstName = firstName
        self._showAddTask = showAddTask
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            switch manager.loadingState {
            case .loading:
                ProgressView()
            case .error(let error):
                ContentUnavailableView("Unable to load data", systemImage: "exclamationmark.triangle", description: Text(error.localizedDescription))
            case .idle:
                content
                    .environment(manager)
                    .applyToolbar(firstName: firstName, showAddTask: $showAddTask)
            }
        }
        .task {
            await manager.loadAllData()
        }
    }
}

struct TabBar: View {
    @Environment(DataManager.self) private var manager
    @State private var selectedTab: TabSelection = .home
    @State private var showAddTask: Bool = false
    
    var body: some View {
        if let user = manager.currentUser {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    TabContentView(firstName: user.firstName, showAddTask: $showAddTask) {
                        HomeView()
                    }
                }
                
                Tab("Tasks", systemImage: "list.bullet.clipboard", value: .tasks) {
                    TabContentView(firstName: user.firstName, showAddTask: $showAddTask) {
                        TasksView()
                    }
                }
                
                Tab("Sessions", systemImage: "brain", value: .sessions) {
                    TabContentView(firstName: user.firstName, showAddTask: $showAddTask) {
                        ProfileView()
                    }
                }
                
                Tab("Habits", systemImage: "repeat.circle.fill", value: .habits) {
                    TabContentView(firstName: user.firstName, showAddTask: $showAddTask) {
                        ProfileView()
                    }
                }
                
                Tab("Insights", systemImage: "chart.bar.fill", value: .insights) {
                    TabContentView(firstName: user.firstName, showAddTask: $showAddTask) {
                        ProfileView()
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                manager.checkCurrentUser()
            } content: {
                AddTaskView()
                    .environment(manager)
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { manager.showingAlert },
                    set: { _ in manager.clearAlertError() }
                )
            ) {
                Button("OK") {
                    manager.clearAlertError()
                }
            } message: {
                if let alertError = manager.alertError {
                    Text(alertError.message)
                }
            }
        }
    }
}

#Preview {
    TabBar()
        .environment(DataManager(currentUser: User.example))
}
