//
//  ScienceView.swift
//  MindApp
//
//  Created by Daniel Davidík on 12.05.2024.
//

import SwiftUI

struct ScienceView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let science = sessionViewModel.activity.localization[0].scienceDesc {
                    Text("\(science)")
                        .font(.appSenBody)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScienceView()
        .environmentObject(SessionViewModel.mock())
}
