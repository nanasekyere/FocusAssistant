//
//  ProfileView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(SignInVM.self) private var authVM
    
    var body: some View {
        @Bindable var authVM = authVM
        if let user = authVM.currentUser {
            VStack(alignment: .center, spacing: 20) {
                // Header Section
                VStack(spacing: 16) {
                    // Profile Image/Avatar
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(String(user.firstName.first ?? "U").uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    
                    Text("Staying Focused \(user.firstName)?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 30)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Profile Actions Section
                VStack(spacing: 12) {
                    // Sign Out Button
                    Button(action: {
                        authVM.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.title2)
                            Text("Sign Out")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Version Info
                    Text("Version \(AppVersion())")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .alert("Sign out error", isPresented: $authVM.showError) {
                Button("OK") {
                    authVM.showError = false
                }
            } message: {
                Text(authVM.errorMessage ?? "Unknown error")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(SignInVM(currentUser: User.example))
}
