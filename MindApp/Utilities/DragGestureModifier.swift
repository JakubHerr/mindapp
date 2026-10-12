//
//  DragGestureModifier.swift
//  MindApp
//
//  Created by Daniel Davidík on 07.04.2024.
//

import SwiftUI

struct DragGestureModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    @GestureState private var dragOffset = CGSize.zero

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture().updating($dragOffset, body: { value, _, _ in
                    if value.startLocation.x < 20, value.translation.width > 100 {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
            )
    }
}

extension View {
    func dragGesture() -> some View {
        modifier(DragGestureModifier())
    }
}
