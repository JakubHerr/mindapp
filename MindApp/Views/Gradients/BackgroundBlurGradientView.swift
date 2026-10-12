//
//  BackgroundBlurGradientView.swift
//  MindApp
//
//  Created by Michael Slavev on 25.05.2024.
//

import SwiftUI

struct BackgroundBlurGradientView: View {
    var body: some View {
        VisualEffectBlur(blurStyle: .systemMaterial)
            .edgesIgnoringSafeArea(.all)
    }
}

private struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview {
    BackgroundBlurGradientView()
}
