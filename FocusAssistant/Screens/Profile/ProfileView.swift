//
//  ProfileView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(DataManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSignOutView: Bool = false
    
    var body: some View {
        @Bindable var manager = manager
        
        if let user = manager.currentUser {
            ZStack {
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
                    .glassEffect(.regular.tint(.glassSurface), in: .rect(cornerRadius: 40))
                    
                    Form {
                        HStack {
                            NavigationLink("Change Focus Mode"){
                                Text("Change")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                        }.listRowBackground(Color(.surfacePrimary))
                        
                        HStack {
                            Image(systemName: "questionmark.circle")
                            
                            Text("Help")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .glassEffect(.regular.tint(.glassSurface).interactive())
                        
                        HStack {
                            Image(systemName: "info.circle")
                            
                            Text("About")
                                .font(.headline)
                                .fontWeight(.medium)
                        }.listRowBackground(Color(.surfacePrimary))
                    }
                    .listRowSpacing(12)
                    .scrollContentBackground(.hidden)
                    
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
                            .glassEffect(.regular.tint(.glassSurface).interactive())
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
                .alert(
                    "Error",
                    isPresented: Binding(
                        get: { manager.showingAlert },
                        set: { _ in manager.clearAlertError() }
                    )
                ) {
                    Button("OK") {
                        manager.clearAlertError()
                    }
                } message: {
                    if let alertError = manager.alertError {
                        Text(alertError.message)
                    }
                }
                .alert("Are you sure you want to sign out?", isPresented: $showSignOutView) {
                    
                    Button("Sign Out") {
                        manager.signOut()
                    }
                    .foregroundStyle(.red)
                    
                    Button(role: .cancel) { }
                }
            }
        }
    }
}

#Preview(traits: .previewBackground) {
    ProfileView()
}
