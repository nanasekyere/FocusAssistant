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
            // Light base gradient - mirroring dark mode structure
            LinearGradient(
                colors: [
                    Color.white,
                    Color.gray.opacity(0.1),
                    Color.cyan.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Purple accent at top (like dark mode)
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
            
            // Cyan glow accent at bottom (like dark mode)
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
            
            // Subtle highlight texture for depth (opposite of dark mode)
            EllipticalGradient(
                colors: [Color.white.opacity(0.4), Color.clear],
                center: .center,
                startRadiusFraction: 0.3,
                endRadiusFraction: 1.0
            )
            .blendMode(.softLight)
        }
    }
    
    private var darkModeBackground: some View {
        ZStack {
            // Dark base gradient - swapped to start with purple at top
            LinearGradient(
                colors: [
                    Color.black,
                    Color.gray.opacity(0.8),
                    Color.cyan.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Purple accent at top
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
            
            // Cyan glow accent at bottom (away from tab bar area)
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
            
            // Subtle noise texture for depth
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
