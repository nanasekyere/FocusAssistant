//
//  TasksView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 18/10/2025.
//

import SwiftUI

struct TasksView: View {
    @Environment(DataManager.self) var manager
    
    var body: some View {
        VStack {
            Group {
                if manager.tasks.isEmpty {
                    ContentUnavailableView("No Tasks", systemImage: "checklist", description: Text("Add a task to get started."))
                } else {
                    List {
                        ForEach(manager.tasks) { task in
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { completeTask(task) }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                    .refreshable {
                        do { try await manager.fetchTasks() }
                        catch { manager.alertError = .failed(.task, .fetch) }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                if !manager.tasks.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                }
            }
        }
    }
    
    private func completeTask(_ task: UserTask) {
        Task {
            try await manager.completeTask(task)
        }
    }
    
}

#Preview {
    TasksView()
        .environment(DataManager(currentUser: User.example))
}
