//
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI
import ButtonKit

struct HomeView: View {
    @Environment(DataManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    @State var selected: HomeFilter = .summary
    
    var body: some View {
        @Bindable var manager = manager
        if let user = manager.currentUser {
            ScrollView {
                VStack {
                    Group {
                        DailyTaskCompletionView(completedCount: manager.completedTodaysTasks.count, totalCount: manager.todaysTasks.count)
                    }
                    .padding(30)
                    .glassEffect(.regular.tint(.glassSurface), in: .rect(cornerRadius: 30))
                    
                    Group {
                        VStack {
                            HStack {
                                Text("Tasks")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("See All →") {}
                            }
                            
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 16) {
                                    if manager.todaysTasks.isEmpty {
                                        EmptyTasksView()
                                    } else {
                                        ForEach(manager.todaysTasks.prefix(5)) { task in
                                            TaskBox(task: task)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .scrollIndicators(.hidden)
                            
                            HStack {
                                Text("Trends")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("See All →") {}
                            }
                            
                            ScrollView(.horizontal) {
                                
                            }
                            
                            HStack {
                                Text("Streaks")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("See All →") {}
                            }
                            
                            ScrollView(.horizontal) {
                                
                            }
                        }
                    }
                    .padding()
                    
                }
                .navigationTitle("Welcome Back, \(user.firstName)")
            }
            .scrollClipDisabled(true)
            .scrollContentBackground(.hidden)
        }
    }
}


struct TaskBox: View {
    let task: UserTask
    @Environment(DataManager.self) private var manager
    
    var body: some View {
    }
}

#Preview(traits: .previewData) {
    TabBar()
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            
            Text("All caught up!")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("No tasks scheduled for today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(width: 280)
        .glassEffect(.regular.tint(.glassSurface), in: .rect(cornerRadius: 16))
    }
}
