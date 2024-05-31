//
//  TabView.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 27/05/2024.
//

import SwiftUI
import TabBar


struct Tabs: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var selection: Item = .third

    var body: some View {
        TabBar(selection: $selection) {
            HomeView()
                .tabItem(for: Item.first)
            TaskView()
                .tabItem(for: Item.second)
            NewTaskView()
                .tabItem(for: Item.third)
            BlenderView()
                .tabItem(for: Item.fourth)
            SettingsView()
                .tabItem(for: Item.fifth)
        }
        
        .tabBar(style: CustomTabBarStyle())
        .tabItem(style: CustomTabItemStyle())
    }
}
enum Item: Int, Tabbable {
    case first = 0
    case second
    case third
    case fourth
    case fifth

    var icon: String {
        switch self {
            case .first:  "house"
            case .second: "checklist"
            case .third:  "plus.app.fill"
            case .fourth: "wand.and.stars"
            case .fifth: "gearshape.fill"
        }
    }

    var title: String {
        switch self {
            case .first: "Home"
            case .second: "Tasks"
            case .third:  "New Task"
            case .fourth: "Blender"
            case .fifth: "Settings"
        }
    }
}

struct CustomTabBarStyle: TabBarStyle {
    public func tabBar(with geometry: GeometryProxy, itemsContainer: @escaping () -> AnyView) -> some View {
        itemsContainer()
            .background(Color.bg2)
            .cornerRadius(25.0)
            .frame(height: 50.0)
            .padding(.horizontal, 32.0)
            .padding(.bottom, geometry.safeAreaInsets.bottom)
    }
}

struct CustomTabItemStyle: TabItemStyle {
    public func tabItem(icon: String, title: String, isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundColor(.accentColor)
                    .frame(width: 40.0, height: 40.0)
            }

            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(isSelected ? .white : .text2)
                .frame(width: 20.0, height: 20.0)
                .shadow(radius: 10)
        }
        .padding(.vertical, 8.0)
    }

}
#Preview {
    Tabs()
}
