//
//  ErrorHandlingExampleView.swift
//  FocusAssistant
//
//  Created by Assistant on 26/10/2025.
//

import SwiftUI

struct ErrorHandlingExampleView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var taskTitle = ""
    @State private var isCreatingTask = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Example of handling loading state
                Group {
                    switch dataManager.loadingState {
                    case .idle:
                        Text("Ready")
                            .foregroundColor(.green)
                    case .loading:
                        ProgressView("Loading...")
                    case .error(let error):
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text("Loading Error: \(error.localizedDescription)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .frame(height: 50)
                
                Divider()
                
                // Example of task creation with alert error handling
                VStack(spacing: 16) {
                    TextField("Task title", text: $taskTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Create Task") {
                        createTask()
                    }
                    .disabled(taskTitle.isEmpty || isCreatingTask)
                    .opacity(taskTitle.isEmpty || isCreatingTask ? 0.6 : 1.0)
                }
                
                Spacer()
                
                // Display tasks
                List(dataManager.tasks, id: \.id) { task in
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)
                        if let dueDate = task.dueDate {
                            Text("Due: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions {
                        Button("Delete") {
                            deleteTask(task)
                        }
                        .tint(.red)
                        
                        Button(task.isCompleted ? "Uncomplete" : "Complete") {
                            toggleTaskCompletion(task)
                        }
                        .tint(task.isCompleted ? .orange : .green)
                    }
                }
            }
            .padding()
            .navigationTitle("Error Handling Example")
            .alert(item: $dataManager.alertError) { alertError in
                Alert(
                    title: Text(alertError.title),
                    message: Text(alertError.message),
                    dismissButton: .default(Text("OK")) {
                        dataManager.clearAlertError()
                    }
                )
            }
        }
    }
    
    private func createTask() {
        isCreatingTask = true
        let newTask = UserTask(
            id: UUID().uuidString,
            title: taskTitle,
            description: nil,
            isCompleted: false,
            priority: .medium,
            dueDate: nil,
            scheduledDate: nil,
            createdAt: Date(),
            updatedAt: Date(),
            completedAt: nil
        )
        
        Task {
            do {
                try await dataManager.createTask(newTask)
                await MainActor.run {
                    taskTitle = ""
                    isCreatingTask = false
                }
            } catch {
                await MainActor.run {
                    isCreatingTask = false
                }
                // Error is already handled by DataManager's alertError
            }
        }
    }
    
    private func deleteTask(_ task: UserTask) {
        Task {
            do {
                try await dataManager.deleteTask(task)
            } catch {
                // Error is handled by DataManager's alertError
            }
        }
    }
    
    private func toggleTaskCompletion(_ task: UserTask) {
        Task {
            do {
                if task.isCompleted {
                    try await dataManager.uncompleteTask(task)
                } else {
                    try await dataManager.completeTask(task)
                }
            } catch {
                // Error is handled by DataManager's alertError
            }
        }
    }
}

#Preview {
    ErrorHandlingExampleView()
        .environment(DataManager(isTest: true))
}