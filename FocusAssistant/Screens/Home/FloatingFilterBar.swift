//
//  FloatingFilterBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 15/11/2025.
//

import SwiftUI

enum HomeFilter: CaseIterable {
    case summary
    case tasks
    case habits
    case sessions
    
    
    var label: String {
        switch self {
        case .summary: return "Summary"
        case .tasks: return "Tasks"
        case .habits: return "Habits"
        case .sessions: return "Sessions"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .summary : HomeSummaryView()
        case .tasks: HomeTasksView()
        case .habits: HomeHabitsView()
        case .sessions: HomeSessionsView()
        }
    }
}

struct FloatingFilterBar: View {
    
    @Binding var selected: HomeFilter
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                ForEach(HomeFilter.allCases, id: \.self) { filter in
                    Button {
                        selected = filter
                    } label: {
                        Text(filter.label)
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selected == filter ? Color.accentColor : Color.elevatedSurface.opacity(0.6))
                            }
                            .foregroundStyle(selected == filter ? .white : .primary.opacity(0.7))
                            .shadow(
                                color: Color.glowPurple.opacity(0.5),
                                radius: selected == filter ? 8 : 3,
                                y: selected == filter ? 4 : 2
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            selected.view
                .transition(.push(from: .trailing))
                .animation(.easeInOut, value: selected)
        }
    }
}

struct HomeSummaryView: View {
    var body: some View {
        Text("Summary")
            .font(.largeTitle)
    }
}

struct HomeTasksView: View {
    var body: some View {
        Text("Tasks")
            .font(.largeTitle)
    }
}

struct HomeHabitsView: View {
    var body: some View {
        Text("Habits")
            .font(.largeTitle)
    }
}

struct HomeSessionsView: View {
    var body: some View {
        Text("Sessions")
            .font(.largeTitle)
    }
}

#Preview(traits: .previewBackground) {
    @Previewable @State var selected = HomeFilter.summary
    FloatingFilterBar(selected: $selected)
}
