//
//  TaskRow.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 19/10/2025.
//

import SwiftUI

struct TaskRow: View {
    @Environment(DataManager.self) var manager
    @State var task: UserTask
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "circle.checkmark.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : task.priority.color)
                .onTapGesture {
                    Task {
                        if task.isCompleted { try await manager.completeTask(task) } else { try await manager.uncompleteTask(task) }
                    }
                }
            
            VStack(spacing: 5) {
                Text("\(task.title)")
                    .fontWeight(.semibold)
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    TaskRow(task: UserTask.example)
        .environment(DataManager(currentUser: User.example))
}
