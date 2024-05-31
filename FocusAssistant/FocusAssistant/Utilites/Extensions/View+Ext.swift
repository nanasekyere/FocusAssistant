//
//  View+Ext.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 31/05/2024.
//

import SwiftUI


struct Text1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.text)
    }
}

struct Text2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.text2)
    }
}

extension View {
    func text1() -> some View {
        return self.modifier(Text1())
    }

    func text2() -> some View {
        modifier(Text2())
    }

}

