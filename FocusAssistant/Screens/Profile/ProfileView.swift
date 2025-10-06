//
//  ProfileView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 06/10/2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            
            
            
            Spacer()
            
            Text("Version \(AppVersion())")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProfileView()
}
