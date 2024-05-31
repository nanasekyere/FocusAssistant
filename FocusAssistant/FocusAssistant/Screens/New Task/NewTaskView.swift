//
//
//  NewTaskView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 28/05/2024.
//
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @State var vm = NewTaskViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(TaskType.allCases) { taskType in
                        Rectangle()
                            .shadow(radius: 20)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                            .frame(height: 400)

                            .cornerRadius(30.0)
                            .foregroundStyle(.bg2)
                            .shadow(color: .black.opacity(0.2), radius: 25)
                            .overlay {
                                NewTaskCard(taskType: taskType)
                            }
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 1)
                                    .scaleEffect(x: phase.isIdentity ? 1 : 0.8,
                                                 y: phase.isIdentity ? 1 : 0.7)
                            }
                            .onTapGesture {

                            }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(54, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
        }

    }


}

struct NewTaskCard: View {
    let taskType: TaskType
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: taskType.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100, alignment: .center)
                .text1()
            Text("\(taskType.rawValue) Task")
                .font(.title.bold())
                .frame(alignment: .center)
                .text1()
            Text(taskType.description)
                .multilineTextAlignment(.center)
                .text2()



        }
        .padding(35)
    }
}

enum TaskType: String, CaseIterable, Identifiable {

    var id: Self {
        return self
    }

    case Regular, Recurring, Pomodoro, Blended

    var imageName: String {
        switch self {
            case .Regular:
                return "checklist"
            case .Recurring:
                return "arrow.counterclockwise"
            case .Pomodoro:
                return "clock.arrow.circlepath"
            case .Blended:
                return "list.bullet.indent"
        }
    }

    var description: String {
        switch self {
            case .Regular:
                return "Regular old task"
            case .Recurring:
                return "Recurring Task"
            case .Pomodoro:
                return "Pomodoro Task"
            case .Blended:
                return "Blended Task; task with subtasks"
        }
    }
}

#Preview {
    Tabs()
}
