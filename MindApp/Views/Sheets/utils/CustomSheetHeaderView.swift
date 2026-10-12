//
//  CustomSheetHeaderView.swift
//  MindApp
//
//  Created by Michael Slavev on 02.05.2024.
//

import SwiftUI

struct CustomSheetHeaderView: View {
    let withBackButton: Bool
    let action: () -> Void?

    init(withBackButton: Bool, action: @escaping () -> Void = {}) {
        self.withBackButton = withBackButton
        self.action = action
    }

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.appBackgroundGradientTop)
                    .frame(width: 40, height: 4)
                    .padding(.top, 4)

                Spacer()
            }.padding(.bottom, 0)

            if withBackButton {
                HStack {
                    Spacer()

                    Button(action: {
                        action()
                    }) {
                        Label("Close", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.appButtonMain)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 10))
                }
            }
        }
    }
}

#Preview {
    CustomSheetHeaderView(withBackButton: true) {}
}
