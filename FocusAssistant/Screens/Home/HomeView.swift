//
//  HomeView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI
import ButtonKit

struct HomeView: View {
    @Environment(DataManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    @State var selected: HomeFilter = .summary
    
    var body: some View {
        @Bindable var manager = manager
        if let user = manager.currentUser {
            ScrollView {
                VStack {
                    Group {
                        DailyTaskCompletionView(completedCount: manager.completedTodaysTasks.count, totalCount: manager.todaysTasks.count)
                    }
                    .padding(30)
                    .glassEffect(.regular.tint(.glassSurface), in: .rect(cornerRadius: 30))
                    
                    Group {
                        FloatingFilterBar(selected: $selected)
                    }
                    .padding()
                    
                }
                .navigationTitle("Welcome Back, \(user.firstName)")
            }
            .scrollClipDisabled(true)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview(traits: .previewData) {
    TabBar()
}
