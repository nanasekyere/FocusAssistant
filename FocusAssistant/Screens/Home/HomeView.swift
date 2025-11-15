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
                    
                    VStack {
                        Group {
                            HStack {
                                Text("Tasks")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("See All →") {}
                            }
                            
                            if manager.todaysTasks.isEmpty {
                                EmptyTasksView()
                            } else {
                                ScrollView(.horizontal) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(manager.todaysTasks.prefix(5)) { task in
                                            TaskBox(task: task)
                                                .glassEffect(.regular.interactive().tint(.glassSurface), in: .rect(cornerRadius: 24))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .scrollIndicators(.hidden)
                                .scrollClipDisabled(true)
                            }
                        }
                        Group {
                            HStack {
                                Text("Trends")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("See All →") {}
                            }
                            
                            ScrollView(.horizontal) {
                                
                            }
                        }
                        Group {
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

#Preview(traits: .previewData) {
    TabBar()
}
