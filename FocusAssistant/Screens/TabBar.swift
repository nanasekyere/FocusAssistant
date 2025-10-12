//
//  TabBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 11/10/2025.
//

import SwiftUI

struct TabBar: View {
    @Environment(AuthVM.self) private var authVM
    
    @State private var activeTab: CustomTab = .home
    
    var body: some View {
        TabView(selection: $activeTab) {
            Tab.init(value: .home) {
                ScrollView(.vertical) {
                    VStack(spacing: 10) {
                        ForEach(1...20, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.red.gradient)
                                .frame(height: 50)
                        }
                    }
                    .padding(15)
                }
                .safeAreaBar(edge: .bottom, spacing: 0, content: {
                    Text(".")
                        .blendMode(.destinationOut)
                        .frame(height: 5)
                })
                .toolbarVisibility(.hidden, for: .tabBar)
                
                Text("Home")
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
            
            Tab.init(value: .analytics) {
                Text("Analytics")
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
            
            Tab.init(value: .profile) {
                Text("Profile")
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBarView()
                .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func CustomTabBarView() -> some View {
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 10) {
                GeometryReader {
                    CustomTabBar(size: $0.size, activeTab: $activeTab)
                        .overlay {
                            HStack(spacing: 0) {
                                ForEach(CustomTab.allCases, id: \.rawValue) { tab in
                                    VStack(spacing: 3) {
                                        Image(systemName: tab.symbol)
                                            .font(.title3)
                                        
                                        Text(tab.rawValue)
                                            .font(.system(size: 10))
                                            .fontWeight(.medium)
                                    }
                                    .symbolVariant(.fill)
                                    .foregroundStyle(activeTab == tab ? Color.primary : Color.primary.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.25), value: activeTab)
                        }
                        .glassEffect(.regular.interactive(), in: .capsule)
                }
                
                ZStack {
                    ForEach(CustomTab.allCases, id: \.rawValue) { tab in
                        Image(systemName: tab.actionSymbol)
                            .font(.system(size: 22, weight: .medium))
                            .blurFade(activeTab == tab)
                    }
                }
                .frame(width: 55, height: 55)
                .glassEffect(.regular.interactive(), in: .capsule)
                .animation(.smooth(duration: 0.55, extraBounce: 0), value: activeTab)
            }
        }
        .frame(height: 55)
        
    }
}
#Preview {
    TabBar()
        .environment(AuthVM(currentUser: User.example))
}
