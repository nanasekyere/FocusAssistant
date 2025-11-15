//
//  TaskBox.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 15/11/2025.
//


import SwiftUI
import ButtonKit

struct TaskBox: View {
    let task: UserTask
    @Environment(DataManager.self) private var manager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with priority and completion status
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
                
                Text(task.priority.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                AsyncButton {
                    try await manager.completeTask(task)
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? Color.success : Color.textSecondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            // Task title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? Color.textSecondary : Color.textPrimary)
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(2)
                }
            }
            
            // Task metadata
            VStack(alignment: .leading, spacing: 6) {
                // Duration and difficulty
                HStack(spacing: 12) {
                    if let duration = task.estimatedDuration {
                        Label {
                            Text("\(duration)m")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "clock")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.textSecondary)
                    }
                    
                    Label {
                        Text(task.difficulty.emoji)
                    } icon: {
                        Text("Difficulty")
                            .font(.caption2)
                    }
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                }
                
                // Due date indicator
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: task.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                            .font(.caption)
                            .foregroundStyle(task.isOverdue ? Color.error : Color.textSecondary)
                        
                        if task.isOverdue {
                            Text("Overdue")
                                .font(.caption2)
                                .foregroundStyle(Color.error)
                                .fontWeight(.medium)
                        } else if task.isDueToday {
                            Text("Due today")
                                .font(.caption2)
                                .foregroundStyle(Color.warning)
                                .fontWeight(.medium)
                        } else {
                            Text(dueDate, format: .dateTime.month().day())
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
                
                // Subtask progress
                if !task.subtasks.isEmpty {
                    HStack(spacing: 6) {
                        ProgressView(value: task.completionPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.faPurple))
                            .frame(height: 4)
                        
                        Text("\(task.subtasks.filter { $0.isCompleted }.count)/\(task.subtasks.count)")
                            .font(.caption2)
                            .foregroundStyle(Color.textSecondary)
                    }
                } else { Spacer() }
            }
            
            
            // Category tag
            if let category = task.category {
                Text(category.rawValue.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.surfaceSecondary, in: .capsule)
                    .foregroundStyle(Color.textSecondary)
                    
            }
        }
        .padding(16)
        .frame(width: 280, height: 180, alignment: .topLeading)
    }
    

}


struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color.success)
            
            Text("All caught up!")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
            
            Text("No tasks scheduled for today")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(16)
        .frame(width: 280)
    }
}
