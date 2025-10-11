//
//  ProfileView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthVM.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSignOutView: Bool = false
    
    var body: some View {
        @Bindable var authVM = authVM
        
        if let user = authVM.currentUser {
            VStack(alignment: .center, spacing: 20) {
                // Header Section
                
                VStack(spacing: 16) {
                    // Profile Image/Avatar
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Text(String(user.firstName.first ?? "U").uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray5))
                .clipShape(.rect(cornerRadius: 40))
                .shadow(radius: 12)
                
                Form {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        
                        Text("Help")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    // Sign Out Button
                    Button(action: {
                        showSignOutView = true
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
                        .clipShape(.capsule)
                    }
                    .padding(.horizontal)
                    
                    // Version Info
                    if let appVersion = AppVersion() {
                        Text("Version \(appVersion)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 20)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .alert("Sign out error", isPresented: $authVM.showError) {
                Button("OK") {
                    authVM.showError = false
                }
            } message: {
                Text(authVM.errorMessage ?? "Unknown error")
            }
            .alert("Are you sure you want to sign out?", isPresented: $showSignOutView) {
                Button("Sign Out") {
                    authVM.signOut()
                }
                .foregroundStyle(.red)
                
                Button(role: .cancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthVM(currentUser: User.example))
}
