//
//  SignInVM.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Observation

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
@Observable class AuthVM {
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    var errorMessage: String?
    var showError: Bool = false
    
    var isLoading: Bool = false
    
    // MARK: - Collection References
    private func userCollection() -> CollectionReference {
        return Firestore.firestore().collection("users")
    }
    
    private func tasksCollection() -> CollectionReference {
        return Firestore.firestore().collection("tasks")
    }
    
    private func focusSessionsCollection() -> CollectionReference {
        return Firestore.firestore().collection("focusSessions")
    }
    
    private func habitsCollection() -> CollectionReference {
        return Firestore.firestore().collection("habits")
    }
    
    private func remindersCollection() -> CollectionReference {
        return Firestore.firestore().collection("reminders")
    }
    
    private func dailyStatsCollection() -> CollectionReference {
        return Firestore.firestore().collection("dailyStats")
    }
    
    func getUser() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    init() {
        
    }
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            isLoading = true
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            try await Task.sleep(for: .seconds(1))
            self.userSession = result.user
            await fetchUser()
            showError = false
            isLoading = false
        } catch {
            print("Failed to Sign In with error \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            isLoading = true
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await Task.sleep(for: .seconds(1))
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await userCollection().document(user.id).setData(encodedUser)
            await fetchUser()
            showError = false
            isLoading = false
        } catch {
            print("Failed to create user with error \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    func signOut() {
        do {
            isLoading = true
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            isLoading = false
        } catch {
            print("Failed to sign out with error \(error.localizedDescription)")
            errorMessage = "Failed to sign out with error \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await userCollection().document(uid).getDocument() else { return }
        
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(String(describing: self.currentUser))")
    }
}

