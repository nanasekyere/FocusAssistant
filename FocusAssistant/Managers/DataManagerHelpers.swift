//
//  DataManagerHelpers.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 01/11/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Observation

/// A comprehensive error type for handling data management operations in the Focus Assistant app.
///
/// `DataManagerError` provides structured error handling for various entities and actions
/// throughout the application, making it easier to provide meaningful error messages to users
/// and debug issues during development.
///
/// ## Usage
///
/// Use this error type when performing operations on any of the supported entities:
/// - User authentication and profile management
/// - Task operations (CRUD, completion status)
/// - Focus session management
/// - Habit tracking
/// - Reminder management
/// - Daily statistics updates
///
/// ## Example
///
/// ```swift
/// do {
///     try await createTask(task)
/// } catch {
///     if let dataError = error as? DataManagerError {
///         // Handle specific data manager errors
///         showAlert(dataError)
///     }
/// }
/// ```
///
/// ## Error Cases
///
/// - `notAuthenticated`: User is not signed in when authentication is required
/// - `passwordMismatch`: Passwords don't match during registration or password change
/// - `operationFailed(entity:action:)`: A specific operation failed on a particular entity
///
/// The `operationFailed` case uses nested enums to provide granular error information,
/// allowing for precise error handling and user-friendly error messages.

/// Represents the different types of entities that can be operated on in the app.
///
/// Each case corresponds to a major data model or service in the Focus Assistant application.
/// The raw values provide human-readable names for use in error messages.

/// Represents the different types of operations that can be performed on entities.
///
/// These actions cover the full range of CRUD operations plus specialized actions
/// like authentication, completion tracking, and session management.
/// The raw values provide human-readable action names for use in error messages.
enum DataManagerError: LocalizedError, Equatable {
    enum Entity: String {
        case user = "user"
        case task = "task"
        case focusSession = "focus session"
        case habit = "habit"
        case reminder = "reminder"
        case stats = "daily stats"
        case auth = "authentication"
    }
    enum Action: String {
        case fetch = "fetch"
        case create = "create"
        case update = "update"
        case delete = "delete"
        case complete = "complete"
        case uncomplete = "uncomplete"
        case start = "start"
        case pause = "pause"
        case signIn = "sign in"
        case signUp = "sign up"
        case signOut = "sign out"
        case resetPassword = "send password reset"
        case profileUpdate = "update profile"
        case load = "load"
        case snooze = "snooze"
    }
    
    case notAuthenticated
    case passwordMismatch
    case operationFailed(entity: Entity, action: Action)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated"
        case .passwordMismatch:
            return "Passwords do not match"
        case let .operationFailed(entity, action):
            switch (entity, action) {
            case (.auth, .signIn): return "Failed to sign in"
            case (.auth, .signUp): return "Failed to sign up"
            case (.auth, .signOut): return "Failed to sign out"
            case (.auth, .resetPassword): return "Failed to send password reset"
            case (.user, .profileUpdate): return "Failed to update profile"
            case (.user, .delete): return "Failed to delete account"
            case (.user, .load): return "Failed to load data"
            case (.task, .fetch): return "Failed to fetch tasks"
            case (.task, .create): return "Failed to create task"
            case (.task, .update): return "Failed to update task"
            case (.task, .delete): return "Failed to delete task"
            case (.task, .complete): return "Failed to complete task"
            case (.task, .uncomplete): return "Failed to uncomplete task"
            case (.focusSession, .fetch): return "Failed to fetch focus sessions"
            case (.focusSession, .start): return "Failed to start focus session"
            case (.focusSession, .pause): return "Failed to pause focus session"
            case (.focusSession, .update): return "Failed to update focus session"
            case (.focusSession, .complete): return "Failed to complete focus session"
            case (.habit, .fetch): return "Failed to fetch habits"
            case (.habit, .create): return "Failed to create habit"
            case (.habit, .update): return "Failed to update habit"
            case (.habit, .complete): return "Failed to complete habit"
            case (.reminder, .fetch): return "Failed to fetch reminders"
            case (.reminder, .create): return "Failed to create reminder"
            case (.reminder, .update): return "Failed to update reminder"
            case (.reminder, .complete): return "Failed to complete reminder"
            case (.reminder, .snooze): return "Failed to snooze reminder"
            case (.stats, .update): return "Failed to update daily stats"
            default:
                return "Operation failed"
            }
        }
    }
}

enum LoadingState: Equatable {
    case idle
    case loading
    case error(DataManagerError)
}

// MARK: - SwiftUI Integration
extension DataManagerError: Identifiable {
    /// Unique identifier for SwiftUI alert presentation.
    /// Uses a hash of the error case for consistent identification.
    var id: Int {
        switch self {
        case .notAuthenticated:
            return 1
        case .passwordMismatch:
            return 2
        case .operationFailed(let entity, let action):
            return "\(entity.rawValue)_\(action.rawValue)".hashValue
        }
    }
    
    /// Standard title for all error alerts.
    var title: String {
        "Error"
    }
    
    /// User-friendly error message from the localized description.
    var message: String {
        localizedDescription
    }
}

// MARK: - Type Alias for Backward Compatibility
/// AlertError is  just a type alias for DataManagerError
/// This eliminates the need for verbose wrapping while maintaining compatibility
typealias AlertError = DataManagerError

// MARK: - Programmatic Error Creation
extension DataManagerError {
    /// Creates an operation failed error programmatically with cleaner syntax
    /// - Parameters:
    ///   - entity: The entity type that failed
    ///   - action: The action that failed
    /// - Returns: A DataManagerError with the specified entity and action
    static func failed(_ entity: Entity, _ action: Action) -> DataManagerError {
        .operationFailed(entity: entity, action: action)
    }
}

protocol FirestoreModel: Codable, Identifiable {
    var id: String? { get set }
    var createdAt: Date { get }
    var updatedAt: Date { get set }
}

struct DataManagerErrorHandling: ViewModifier {
    @Environment(DataManager.self) private var dataManager
    
    func body(content: Content) -> some View {
        @Bindable var dataManager = dataManager
        
        content
            .alert(
                "Error",
                isPresented: Binding(
                    get: { dataManager.showingAlert },
                    set: { _ in dataManager.clearAlertError() }
                )
            ) {
                Button("OK") {
                    dataManager.clearAlertError()
                }
            } message: {
                if let alertError = dataManager.alertError {
                    Text(alertError.message)
                }
            }
    }
}

/// Extension to provide a convenient way to apply DataManager error handling.
extension View {
    /// Applies standardized DataManager error handling to the view.
    ///
    /// This modifier automatically displays error alerts for any DataManager operations
    /// that fail within this view or its child views.
    ///
    /// - Returns: A view with DataManager error handling applied.
    func dataManagerErrorHandling() -> some View {
        modifier(DataManagerErrorHandling())
    }
}

/// A generic, actor-based repository for managing Firestore CRUD operations.
///
/// `FirestoreRepository` provides a type-safe, thread-safe interface for interacting with
/// Firestore collections. It handles encoding/decoding of Swift models to/from Firestore
/// documents and provides standard CRUD operations with proper error handling.
///
/// ## Generic Constraints
///
/// The repository works with any type `T` that conforms to `FirestoreModel`, which provides:
/// - `Codable` conformance for serialization
/// - `Identifiable` for unique document identification
/// - Timestamp tracking with `createdAt` and `updatedAt` properties
///
/// ## Thread Safety
///
/// This repository is implemented as an `actor` to ensure thread-safe access to Firestore
/// operations. All methods are `async` and should be called with `await`.
///
/// ## Usage
///
/// ```swift
/// let taskRepository = FirestoreRepository<Task>(
///     collection: Firestore.firestore().collection("tasks")
/// )
///
/// // Create a new task
/// try await taskRepository.create(newTask)
///
/// // Fetch all tasks for a user
/// let userTasks = try await taskRepository.fetchAll { query in
///     query.whereField("userId", isEqualTo: userId)
/// }
/// ```
///
/// ## Error Handling
///
/// All methods throw errors for various failure scenarios:
/// - Missing document IDs when creating, updating, or deleting
/// - Firestore network or permission errors
/// - Encoding/decoding failures for malformed data
///
/// ## Performance Considerations
///
/// - Uses Firestore's built-in encoder/decoder for optimal performance
/// - Supports query modification for efficient data filtering
/// - Implements proper merge strategies for updates to avoid data loss

/// Initializes a new repository for the specified Firestore collection.
///
/// - Parameter collection: The Firestore collection reference to operate on.
///   This collection should contain documents that can be decoded as type `T`.

/// Creates a new document in the Firestore collection.
///
/// The item's `id` property must be set before calling this method. The document
/// will be created with this ID in Firestore.
///
/// - Parameter item: The model instance to create. Must have a non-nil `id` property.
/// - Throws: An error if the item's ID is missing or if the Firestore operation fails.

/// Updates an existing document in the Firestore collection.
///
/// Uses Firestore's merge capability to update only the provided fields while
/// preserving existing data. The item's `id` property determines which document to update.
///
/// - Parameter item: The model instance with updated data. Must have a non-nil `id` property.
/// - Throws: An error if the item's ID is missing or if the Firestore operation fails.

/// Deletes a document from the Firestore collection.
///
/// The document is identified by the item's `id` property and permanently removed
/// from the collection.
///
/// - Parameter item: The model instance to delete. Must have a non-nil `id` property.
/// - Throws: An error if the item's ID is missing or if the Firestore operation fails.

/// Fetches all documents from the collection with optional query filtering.
///
/// This method retrieves all documents that match the optional query criteria.
/// Documents that fail to decode are silently filtered out to maintain data integrity.
///
/// - Parameter query: An optional closure that receives the base `Query` and returns
///   a modified query with additional filters, ordering, or limits applied.
/// - Returns: An array of decoded model instances that match the query criteria.
/// - Throws: An error if the Firestore query operation fails.
///
/// ## Query Examples
///
/// ```swift
/// // Fetch all documents
/// let allItems = try await repository.fetchAll()
///
/// // Fetch with filtering
/// let recentItems = try await repository.fetchAll { query in
///     query.whereField("createdAt", isGreaterThan: Date().addingTimeInterval(-86400))
///          .order(by: "createdAt", descending: true)
///          .limit(to: 10)
/// }
/// ```

/// Fetches a single document by its ID.
///
/// - Parameter id: The unique identifier of the document to retrieve.
/// - Returns: The decoded model instance if the document exists and can be decoded,
///   or `nil` if the document doesn't exist.
/// - Throws: An error if the Firestore operation fails or if decoding fails.
/// A ViewModifier that provides standardized error handling for DataManager operations.
///
/// This modifier automatically displays error alerts for any DataManager errors that are
/// stored in the `alertError` property. It provides a consistent user experience across
/// all views that interact with the DataManager.
///
/// ## Usage
///
/// Apply this modifier to any view that performs DataManager operations:
///
/// ```swift
/// struct MyView: View {
///     @Environment(DataManager.self) private var dataManager
///
///     var body: some View {
///         VStack {
///             // Your view content
///         }
///         .dataManagerErrorHandling()
///     }
/// }
/// ```
///
/// ## Features
///
/// - **Automatic Error Display**: Shows an alert whenever `DataManager.alertError` is set
/// - **User-Friendly Messages**: Displays localized error messages from `DataManagerError`
/// - **Consistent UI**: Standardizes error presentation across the entire app
/// - **Easy Dismissal**: Provides an "OK" button that clears the error state
///
/// ## Integration
///
/// This modifier works seamlessly with the DataManager's error handling pattern:
/// 1. DataManager operations set `alertError` when they fail
/// 2. This modifier automatically detects the error and shows an alert
/// 3. User dismisses the alert, which clears the error state
/// 4. App continues normal operation
actor FirestoreRepository<T: FirestoreModel> {
    private let collection: CollectionReference
    private let encoder = Firestore.Encoder()
    private let decoder = Firestore.Decoder()
    
    init(collection: CollectionReference) {
        self.collection = collection
    }
    
    // Create a new document
    func create(_ item: T) async throws {
        guard let id = await item.id else {
            throw NSError(domain: "Repository", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Item ID is missing"])
        }
        let encodedItem = try encoder.encode(item)
        try await collection.document(id).setData(encodedItem)
    }
    
    // Update an existing document
    func update(_ item: T) async throws {
        guard let id = await item.id else {
            throw NSError(domain: "Repository", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Item ID is missing"])
        }
        let encodedItem = try encoder.encode(item)
        try await collection.document(id).setData(encodedItem, merge: true)
    }
    
    // Delete a document
    func delete(_ item: T) async throws {
        guard let id = await item.id else {
            throw NSError(domain: "Repository", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Item ID is missing"])
        }
        try await collection.document(id).delete()
    }
    
    // Fetch all documents with optional query modifications
    func fetchAll(query: ((Query) -> Query)? = nil) async throws -> [T] {
        var baseQuery: Query = collection
        
        if let queryModifier = query {
            baseQuery = queryModifier(baseQuery)
        }
        
        let snapshot = try await baseQuery.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? decoder.decode(T.self, from: doc.data())
        }
    }
    
    // Fetch a single document by ID
    func fetch(id: String) async throws -> T? {
        let doc = try await collection.document(id).getDocument()
        guard doc.exists else { return nil }
        return try decoder.decode(T.self, from: doc.data() ?? [:])
    }
}
