//
//  OverviewView.swift
//  MindApp
//
//  Created by Daniel Davidík on 02.05.2024.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(sessionViewModel.activity.localization[0].overview ?? "")
                    .font(.appSenBody)

                Text("tips")
                    .font(.appSenTitle)
                    .bold()
                    .padding(.top)

                SheetInfoSectionView(innerPadding: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(sessionViewModel.activity.localization[0].tips ?? [], id: \.self) { tip in
                            Text("• \(tip)")
                        }
                    }
                    .font(.appSenBody)
                }

                Text("mind_session_safety_notes")
                    .font(.appSenTitle)
                    .bold()
                    .padding(.top)

                SheetInfoSectionView(innerPadding: false) {
                    if sessionViewModel.activity.category == .breathing {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("mind_session_breathing_safety_1")
                            Text("mind_session_breathing_safety_2")
                            Text("mind_session_breathing_safety_3")
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("mind_session_meditation_safety_1")
                            Text("mind_session_meditation_safety_2")
                            Text("mind_session_meditation_safety_3")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    OverviewView()
        .environmentObject(SessionViewModel.mock())
}
