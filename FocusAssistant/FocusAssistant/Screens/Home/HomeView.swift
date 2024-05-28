//
//  
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//
//

import SwiftUI
import SwiftData
import SwiftUI_FAB

struct HomeView: View {
    @State var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Hello, Home!")
            }
        }
    }
}

#Preview {
    HomeView()
}
