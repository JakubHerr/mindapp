//
//  TrendsToggleButtonView.swift
//  MindApp
//
//  Created by Michael Slavev on 16.04.2024.
//

import SwiftUI

struct TrendsToggleButtonView: View {
    @Binding var displayMode: TrendsView.DisplayMode

    private var isWeekly: Bool {
        displayMode == .weekly
    }

    // MARK: View building

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Text views
                HStack {
                    Text("trends_toggle_weekly")
                        .font(.appSenBody)
                        .foregroundColor(!isWeekly ? .white : .appTextDark)
                        .frame(maxWidth: .infinity)
                        .padding()

                    Text("trends_toggle_monthly")
                        .font(.appSenBody)
                        .foregroundColor(isWeekly ? .white : .appTextDark)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.appButtonMain)
                .clipShape(Capsule())

                // Animated sliding capsule
                Capsule()
                    .fill(Color.appButtonAccent)
                    .frame(width: (geometry.size.width / 2) - 15, height: 36)
                    .offset(x: isWeekly ? -geometry.size.width / 4 : geometry.size.width / 4, y: 0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isWeekly)

                // Text on top of the mask
                HStack {
                    Text("trends_toggle_weekly")
                        .font(.appSenBody)
                        .foregroundColor(!isWeekly ? .white : .appTextDark)
                        .frame(maxWidth: .infinity)
                        .padding()

                    Text("trends_toggle_monthly")
                        .font(.appSenBody)
                        .foregroundColor(isWeekly ? .white : .appTextDark)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .mask(
                    Capsule()
                        .fill(Color.appButtonAccent)
                        .frame(width: (geometry.size.width / 2) - 15, height: 36)
                        .offset(x: isWeekly ? -geometry.size.width / 4 : geometry.size.width / 4, y: 0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isWeekly)
                )
            }
        }
        .frame(height: 36)
        .onTapGesture {
            withAnimation {
                displayMode.toggle()
            }
        }
        .padding()
    }
}

struct TrendsToggleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TrendsToggleButtonView(displayMode: .constant(.weekly))
    }
}
