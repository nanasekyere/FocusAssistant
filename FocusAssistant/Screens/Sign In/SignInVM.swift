//
//  SignInVM.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//


import SwiftUI
import FirebaseAuth

@MainActor
@Observable final class SignInVM {
    var user: User?
    var errorMessage: String?
    var showError: Bool = false
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                // If there's an error, update the errorMessage to display it
                self?.errorMessage = error.localizedDescription
                self?.showError = true
                return
            }
            // On successful login, update the user property
            self?.user = result?.user
            self?.errorMessage = nil
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.showError = true
                return
            }
            self?.user = result?.user
            self?.errorMessage = nil
            self?.showError = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.errorMessage = nil
            self.showError = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
}

