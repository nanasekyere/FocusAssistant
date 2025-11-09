//
//  ApplyToolbar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 18/10/2025.
//

import SwiftUI

extension View {
    func applyToolbar(firstName: String, showAddTask: Binding<Bool>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    ProfileView()
                } label: {
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Text(String(firstName.first ?? "U").uppercased())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddTask.wrappedValue.toggle()
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
    }
}
