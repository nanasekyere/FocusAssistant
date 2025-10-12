//
//  CustomTabBar.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 12/10/2025.
//

import SwiftUI

struct CustomTabBar: UIViewRepresentable {
    var size: CGSize
    var barTint: Color = .gray.opacity(0.2)
    @Binding var activeTab: CustomTab
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let items = CustomTab.allCases.compactMap({ _ in "" })
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = activeTab.index
        
        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }
        
        control.selectedSegmentTintColor = UIColor(barTint)
        
        control.addTarget(context.coordinator, action: #selector(context.coordinator.tabSelected(_:)), for: .valueChanged)
        return control
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        return size
    }
    
    class Coordinator: NSObject {
        var parent: CustomTabBar
        init(parent: CustomTabBar) {
            self.parent = parent
        }
        
        @objc func tabSelected(_ control: UISegmentedControl) {
            parent.activeTab = CustomTab.allCases[control.selectedSegmentIndex]
        }
    }
}

enum CustomTab: String, CaseIterable {
    case home = "Home"
    case analytics = "Analytics"
    case profile = "Profile"
    
    var symbol: String {
        switch self {
        case .home: return "house"
        case .analytics: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
    
    var actionSymbol: String {
        switch self {
        case .home: return "plus"
        case .analytics: return "plus"
        case .profile: return "plus"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

extension View {
    @ViewBuilder
    func blurFade(_ status: Bool) -> some View {
        self
            .compositingGroup()
            .blur(radius: status ? 0 : 10)
            .opacity(status ? 1 : 0)
    }
}

