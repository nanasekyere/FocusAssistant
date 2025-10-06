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
@Observable class SignInVM {
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    var errorMessage: String?
    var showError: Bool = false
    
    func getUser() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            showError = false
        } catch {
            print("Failed to Sign In with error \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            showError = false
        } catch {
            print("Failed to create user with error \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out with error \(error.localizedDescription)")
            errorMessage = "Failed to sign out with error \(error.localizedDescription)"
            showError = true
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(self.currentUser)")
    }
}

