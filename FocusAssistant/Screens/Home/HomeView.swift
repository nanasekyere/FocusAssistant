//
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthVM.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var authVM = authVM
        
        if let user = authVM.currentUser {
            NavigationStack {
                VStack {
                    Button("Start Focus Session") {
                        
                    }
                }
                .navigationTitle("Staying focused, \(user.firstName)?")
                .toolbar {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Circle()
                            .fill(.blue.gradient)
                            .overlay {
                                Text(String(user.firstName.first ?? "U").uppercased())
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 36, height: 36)
                    }

            }
            
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthVM(currentUser: User.example))
}
