# Error Handling Strategy for DataManager

## Overview
The updated DataManager now uses a dual error handling approach that distinguishes between:
1. **Loading State Errors**: For data fetching operations that affect the UI's loading state
2. **Alert Errors**: For user actions that should show immediate feedback via alerts

## Error Types

### LoadingState
- `idle`: No current operation
- `loading`: Data is being fetched
- `error(DataManagerError)`: Data fetching failed

### AlertError
- `dataManagerError(DataManagerError)`: Wraps DataManager errors for alert presentation
- Conforms to `Identifiable` for SwiftUI alert handling
- Provides `title` and `message` properties

## Usage Guidelines

### Use Loading State Errors For:
- `fetchTasks()`, `fetchHabits()`, `fetchReminders()`, `fetchFocusSessions()`
- `loadAllData()`
- Real-time listener failures
- Authentication state loading (`signIn`, `signUp`)

### Use Alert Errors For:
- `createTask()`, `updateTask()`, `deleteTask()`
- `completeTask()`, `uncompleteTask()`
- `createHabit()`, `updateHabit()`, `completeHabit()`
- `createReminder()`, `updateReminder()`, `completeReminder()`
- User profile operations

## Implementation in Views

### Loading State Handling
```swift
switch dataManager.loadingState {
case .idle:
    // Show normal UI
case .loading:
    ProgressView("Loading...")
case .error(let error):
    Text("Error: \(error.localizedDescription)")
        .foregroundColor(.red)
}
```

### Alert Error Handling
```swift
.alert(item: $dataManager.alertError) { alertError in
    Alert(
        title: Text(alertError.title),
        message: Text(alertError.message),
        dismissButton: .default(Text("OK")) {
            dataManager.clearAlertError()
        }
    )
}
```

### Task Operations Example
```swift
private func createTask() {
    Task {
        do {
            try await dataManager.createTask(newTask)
            // Success - continue with UI updates
        } catch {
            // Error is automatically shown as alert
            // No need to handle error manually
        }
    }
}
```

## Benefits

1. **Better UX**: Users get immediate feedback for their actions via alerts
2. **Cleaner Loading States**: Loading indicators only show for actual data loading
3. **Separation of Concerns**: Different error types for different user scenarios
4. **Consistent Behavior**: All CRUD operations use alerts, all fetch operations use loading states
5. **Easy to Use**: Views just need to observe `alertError` and show alerts

## Helper Methods

- `setLoadingError(_:)`: Sets loading state error
- `setAlertError(_:)`: Sets alert error
- `clearAlertError()`: Clears current alert error (call in alert dismiss handler)