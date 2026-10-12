//
//  SettAboutHrvInfoSheet.swift
//  MindApp
//
//  Created by Michael Slavev on 15.05.2024.
//

import SwiftUI

struct FaqAboutHrvInfoSheet: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    let whatHeaderLabel = NSLocalizedString("infosheet_faq_hrv_what_header", comment: "Header of what is hrv info section")
    let whatTextLabel = NSLocalizedString("infosheet_faq_hrv_what_text", comment: "Text of what is hrv info section")

    let higherHeaderLabel = NSLocalizedString("infosheet_faq_hrv_higher_header", comment: "Header of is higher better info section")
    let higherTextLabel = NSLocalizedString("infosheet_faq_hrv_higher_text", comment: "Text of is higher better info section")

    let controlHeaderLabel = NSLocalizedString("infosheet_faq_hrv_control_header", comment: "Header of what can you control info section")
    let controlTextLabel = NSLocalizedString("infosheet_faq_hrv_control_text", comment: "Text of what can you control info section")

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: viewModel.toggleAboutHrvInfoSheet)

                // MARK: Content

                ScrollView {
                    SheetInfoSectionView(sectionHeaderText: whatHeaderLabel, content: {
                        VStack {
                            Text(whatTextLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                        }
                    })

                    SheetInfoSectionView(sectionHeaderText: higherHeaderLabel, content: {
                        VStack {
                            Text(higherTextLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                        }
                    })

                    SheetInfoSectionView(sectionHeaderText: controlHeaderLabel, content: {
                        VStack {
                            Text(controlTextLabel)
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
    FaqAboutHrvInfoSheet()
        .environmentObject(SettingsViewModel.mock())
}
