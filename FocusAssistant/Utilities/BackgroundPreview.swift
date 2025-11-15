//
//  BackgroundPreview.swift
//  FocusAssistant
//
//  Created by Nana Sekyere on 09/11/2025.
//

import SwiftUI

struct BackgroundPreviewTrait: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        @Previewable @State var manager = DataManager(isTest: true)
        return ZStack {
            BackgroundView()
                .ignoresSafeArea(.all)
            
            content
                .fontDesign(.rounded)
                .environment(manager)
        }
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static let previewBackground: Self = .modifier(BackgroundPreviewTrait())
}
