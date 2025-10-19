//
//  AddTaskView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 18/10/2025.
//

import SwiftUI
import ButtonKit

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(DataManager.self) var manager
    
    // Form State
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDateEnabled: Bool = false
    @State private var dueDate: Date = Date()
    @State private var priority: Priority = .medium
    @State private var difficulty: Difficulty = .medium
    @State private var energyLevel: EnergyLevel = .medium
    @State private var estimatedDurationText: String = ""
    @State private var category: TaskCategory? = nil
    @State private var tagsText: String = ""
    
    var body: some View {
        @Bindable var manager = manager
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
                
                Section("When") {
                    Toggle("Has due date", isOn: $dueDateEnabled.animation())
                    if dueDateEnabled {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Attributes") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { d in
                            Text(d.rawValue.capitalized).tag(d)
                        }
                    }
                    Picker("Energy", selection: $energyLevel) {
                        ForEach(EnergyLevel.allCases, id: \.self) { e in
                            Text(e.rawValue.capitalized).tag(e)
                        }
                    }
                    Picker("Category", selection: Binding(get: { category }, set: { newValue in
                        category = newValue
                    })) {
                        Text("None").tag(TaskCategory?.none)
                        ForEach(TaskCategory.allCases, id: \.self) { c in
                            Text(c.rawValue.capitalized).tag(Optional(c))
                        }
                    }
                }
                
                Section("Planning") {
                    TextField("Estimated minutes (e.g. 25)", text: $estimatedDurationText)
                        .keyboardType(.numberPad)
                    TextField("Tags (comma separated)", text: $tagsText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    AsyncButton("Save") { try await addTask() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func parsedEstimatedMinutes() -> Int? {
        let trimmed = estimatedDurationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let value = Int(trimmed), value > 0 else { return nil }
        return value
    }
    
    private func parsedTags() -> [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func addTask() async throws {
        let now = Date()
        var task = UserTask(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: notes.isEmpty ? nil : notes,
            estimatedDuration: parsedEstimatedMinutes(),
            dueDate: dueDateEnabled ? dueDate : nil,
            priority: priority,
            difficulty: difficulty,
            energyLevel: energyLevel,
            category: category,
            tags: parsedTags()
        )
        task.createdAt = now
        task.updatedAt = now
        
        Task { @MainActor in
            defer { dismiss() }
            try await manager.createTask(task)
        }
    }
}

#Preview {
    AddTaskView()
        .environment(DataManager(currentUser: User.example))
}
