//
//  TabBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

enum TabSelection: String, CaseIterable, Identifiable {
    case home
    case tasks
    case sessions
    case habits
    case insights
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .sessions: return "Sessions"
        case .habits: return "Habits"
        case .insights: return "Insights"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "list.bullet.clipboard"
        case .sessions: return "brain"
        case .habits: return "repeat.circle.fill"
        case .insights: return "chart.bar.fill"
        }
    }
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()
        case .tasks:
            TasksView()
        case .sessions:
            ProfileView()
        case .habits:
            ProfileView()
        case .insights:
            ProfileView()
        }
    }
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
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
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
                ForEach(TabSelection.allCases) { tab in
                    Tab(tab.title, systemImage: tab.systemImage, value: tab) {
                        TabContentView(firstName: user.firstName, showAddTask: $showAddTask) {
                            tab.view()
                                .dataManagerErrorHandling()
                        }
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

#Preview(traits: .previewData) {
    TabBar()
}

