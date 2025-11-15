//
//  BackgroundView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 09/11/2025.
//

import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                darkModeBackground
            } else {
                lightModeBackground
            }
        }
    }
    
    private var lightModeBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.gray.opacity(0.05),
                    Color.gray.opacity(0.1),
                    Color.cyan.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    Color.faPurple.opacity(0.25),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 80,
                endRadius: 400
            )
            .blendMode(.multiply)

            RadialGradient(
                colors: [
                    Color.cyan.opacity(0.2),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 100,
                endRadius: 350
            )
            .blendMode(.multiply)
            
            EllipticalGradient(
                colors: [Color.gray.opacity(0.2), Color.clear],
                center: .center,
                startRadiusFraction: 0.3,
                endRadiusFraction: 1.0
            )
            .blendMode(.softLight)
        }
    }
    
    private var darkModeBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.gray.opacity(0.8),
                    Color.cyan.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            

            RadialGradient(
                colors: [
                    Color.faPurple.opacity(0.5),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 80,
                endRadius: 400
            )
            .blendMode(.screen)
            
            RadialGradient(
                colors: [
                    Color.cyan.opacity(0.4),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 100,
                endRadius: 350
            )
            .blendMode(.softLight)
            
            EllipticalGradient(
                colors: [Color.white.opacity(0.05), Color.clear],
                center: .center,
                startRadiusFraction: 0.3,
                endRadiusFraction: 1.0
            )
            .blendMode(.overlay)
        }
    }
}

#Preview("Light Mode") {
    BackgroundView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    BackgroundView()
        .preferredColorScheme(.dark)
}
