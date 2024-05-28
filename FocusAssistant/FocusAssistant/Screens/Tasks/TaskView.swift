//
//  
//  TaskView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//
//

import SwiftUI
import SwiftData

struct TaskView: View {
    @State var vm = TaskViewModel()
    
    var body: some View {
        Text("Hello, Tasks!")
    }
}

#Preview {
    TaskView()
}
