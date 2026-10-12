//
//  FaqHowOftenInfoSheet.swift
//  MindApp
//
//  Created by Michael Slavev on 15.05.2024.
//

import SwiftUI

struct FaqHowOftenInfoSheet: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    let frequencyHeaderLabel = NSLocalizedString("infosheet_faq_frequency_often_header", comment: "Header of collection frequency info section")
    let frequencyTextLabel = NSLocalizedString("infosheet_faq_frequency_often_text", comment: "Text of collection frequency info section")

    let manualMeasureHeaderLabel = NSLocalizedString("infosheet_faq_frequency_manualmeasure_header", comment: "Header of manual measurement info section")
    let manualMeasureTextLabel = NSLocalizedString("infosheet_faq_frequency_manualmeasure_text", comment: "Text of manual measurement info section")

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: viewModel.toggleHowOftenInfoSheet)

                // MARK: Content

                ScrollView {
                    SheetInfoSectionView(sectionHeaderText: frequencyHeaderLabel, content: {
                        VStack {
                            Text(.init(frequencyTextLabel))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                        }
                    })

                    SheetInfoSectionView(sectionHeaderText: manualMeasureHeaderLabel, content: {
                        VStack {
                            Text(manualMeasureTextLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                        }
                    })
                }
            }
        }
    }

    // MARK: functions
}

#Preview {
    FaqHowOftenInfoSheet()
        .environmentObject(SettingsViewModel.mock())
}
