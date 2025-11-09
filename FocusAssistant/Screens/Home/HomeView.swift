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
    
    var body: some View {
        @Bindable var manager = manager
        if let user = manager.currentUser {
            ScrollView {
                VStack {
                    Group {
                        DailyTaskCompletionView(completedCount: manager.completedTodaysTasks.count, totalCount: manager.todaysTasks.count)
                    }
                    .padding(30)
                    .background(Color.gray.opacity(0.3))
                    .containerShape(.rect(cornerRadius: 30))
                    
                }
                .navigationTitle("Welcome Back, \(user.firstName)")
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct DailyTaskCompletionView: View {
    @State var completedCount: Int
    @State var totalCount: Int
    
    var percentage: Double {
        guard totalCount > 0 else { return 0 }
        let percent = (Double(completedCount) / Double(totalCount)) * 100
        return percent
    }
    
    var cellText: String {
        switch percentage {
        case 0..<25:
            return "Let's get started!"
        case 25..<50:
            return "Making progress!"
        case 50..<75:
            return "Halfway there!"
        case 75..<100:
            return "Almost done!"
        case 100:
            return "All tasks complete!"
        default:
            return "Keep going"
        }
    }
    
    var body: some View {
        HStack(spacing: 30) {
            VStack(alignment: .leading){
                Text("Today's Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(cellText)
                    .font(.subheadline)
                
                Button("View Tasks"){}
                    .buttonStyle(.glassProminent)
                    .padding(.top, 10)
                
            }
            .frame(alignment: .leading)
            
            CircularProgressView(progress: CGFloat(percentage / 100))
                .frame(width: 100, height: 100)
                .overlay {
                    Text("\(Int(percentage))%")
                        .font(.title)
                        .fontWeight(.bold)
                }
        }
    }
}

struct CircularProgressView: View {
  var progress: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 15)
        .opacity(0.1)
        .foregroundColor(.accentColor)

        
      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
        .foregroundColor(.accentColor)
        .rotationEffect(Angle(degrees: 270.0))
        
    }
  }
}

#Preview(traits: .previewData) {
    TabBar()
}
