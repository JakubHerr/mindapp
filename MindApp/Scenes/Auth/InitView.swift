//
//  InitView.swift
//  MindApp
//
//  Created by Michael Slavev on 22.03.2024.
//

import SwiftUI

struct InitView: View {
    var body: some View {
        ZStack {
            BackgroundLightGradientView()

            VStack {
                VStack {
                    Image("mind-app-transparent")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .foregroundStyle(Color.appLogoMain)
                }
            }
        }
    }
}

#Preview {
    InitView()
}
