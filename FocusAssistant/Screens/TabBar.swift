//
//  TabBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

struct TabBar: View {
    @Environment(AuthVM.self) private var authVM
    
    var body: some View {
        TabView {

            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Today", systemImage: "calendar") {
                Text("Today")
            }
            
            Tab("Analytics", systemImage: "chart.bar.fill") {
                ProfileView()
            }
        }
    }
  
}
#Preview {
    TabBar()
        .environment(AuthVM(currentUser: User.example))
}
