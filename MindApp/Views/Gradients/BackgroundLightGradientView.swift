//
//  BackgroundLightGradientView.swift
//  MindApp
//
//  Created by Daniel Davidík on 21.03.2024.
//

import SwiftUI

struct BackgroundLightGradientView: View {
    var body: some View {
        LinearGradient(
            gradient: .init(colors: [.appBackgroundLightGradientTop, .appBackgroundLightGradientBottom]),
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(Color.black.opacity(0.1))
#if DEBUG
        .border(Color.red, width: 5)
#endif
        .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundLightGradientView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundLightGradientView()
    }
}
