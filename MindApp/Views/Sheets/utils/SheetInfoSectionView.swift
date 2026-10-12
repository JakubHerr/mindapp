//
//  SheetInfoSectionView.swift
//  MindApp
//
//  Created by Michael Slavev on 04.05.2024.
//

import SwiftUI

struct SheetInfoSectionView<Content: View>: View {
    var sectionHeaderText: String?
    var sectionHeaderLocalizedText: LocalizedStringResource?
    var innerPadding: Bool = true
    var content: () -> Content

    var body: some View {
        VStack {
            Section(header: headerView()) {
                VStack {
                    content()
                }
                .font(.appSenBody)
                .padding()
                .background(Color.appBackgroundGradientBottom)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(innerPadding ? [.horizontal] : [])
            }
        }
    }

    // MARK: Functions

    @ViewBuilder
    private func headerView() -> some View {
        if let headerText = sectionHeaderText {
            Text(headerText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.appSenBody)
                .foregroundColor(.appTextBody)
                .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 20))
        }
        else if let localizedText = sectionHeaderLocalizedText {
            Text(localizedText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.appSenBody)
                .foregroundColor(.appTextBody)
                .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 20))
        }
        else {
            EmptyView()
        }
    }
}

// Preview
struct SheetInfoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SheetInfoSectionView(sectionHeaderText: "Example Header", content: {
            Text("This is an example content view.")
        })
    }
}
