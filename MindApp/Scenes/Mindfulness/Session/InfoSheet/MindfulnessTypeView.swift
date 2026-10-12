//
//  MindflnessTypeVIew.swift
//  MindApp
//
//  Created by Daniel Davidík on 12.05.2024.
//

import SwiftUI

struct MindfulnessTypeItem {
    var icon: String
    var text: String
}

struct MindfulnessTypeView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
            ForEach(sessionViewModel.activity.types, id: \.name) { type in
                VStack {
                    Image(systemName: type.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 2)
                    Text(type.localization[0].name)
                        .font(.appSenBody)
                        .frame(height: 20)
                }
                .frame(width: 100, height: 100)
            }
        }
        .padding()
    }
}

#Preview {
    MindfulnessTypeView()
        .environmentObject(SessionViewModel.mock())
}
