//
//  FaqStressMeasureInfoSheet.swift
//  MindApp
//
//  Created by Michael Slavev on 15.05.2024.
//

import SwiftUI

struct FaqStressMeasureInfoSheet: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    let whatHeaderLabel = NSLocalizedString("infosheet_faq_calculation_what_header", comment: "Header of what is hrv info section")
    let whatTextLabel = NSLocalizedString("infosheet_faq_calculation_what_text", comment: "Text of what is hrv info section")

    let whyHeaderLabel = NSLocalizedString("infosheet_faq_calculation_why_header", comment: "Header of why rmssd info section")
    let whyTextLabel = NSLocalizedString("infosheet_faq_calculation_why_text", comment: "Text of why rmssd info section")

    let howHeaderLabel = NSLocalizedString("infosheet_faq_calculation_how_header", comment: "Header of how we measure info section")
    let howTextLabel = NSLocalizedString("infosheet_faq_calculation_how_text", comment: "Text of whow we measure info section")
    
    let stressAtPeaceLabel = NSLocalizedString("infosheet_daily_stress_atpeace_text", comment: "Text label")
    let stressNormalLabel = NSLocalizedString("infosheet_daily_stress_normal_text", comment: "Text label")
    let stressPayAttentionLabel = NSLocalizedString("infosheet_daily_stress_payattention_text", comment: "Text label")
    let stressStressedLabel = NSLocalizedString("infosheet_daily_stress_stressed_text", comment: "Text label")

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: viewModel.toggleStressMeasurementInfoSheet)

                // MARK: Content

                ScrollView {
                    SheetInfoSectionView(sectionHeaderText: whatHeaderLabel, content: {
                        VStack {
                            Text(whatTextLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                        }
                    })

                    SheetInfoSectionView(sectionHeaderText: whyHeaderLabel, content: {
                        VStack {
                            Text(whyTextLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                        }
                    })

                    SheetInfoSectionView(sectionHeaderText: howHeaderLabel, content: {
                        VStack {
                            Text(howTextLabel)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.appSenBody)
                            
                            Divider()

                            makeStressInfoText(stressLevel: .AtPeace, comment: stressAtPeaceLabel)
                            makeStressInfoText(stressLevel: .Normal, comment: stressNormalLabel)
                            makeStressInfoText(stressLevel: .PayAttention, comment: stressPayAttentionLabel)
                            makeStressInfoText(stressLevel: .Stressed, comment: stressStressedLabel)
                        }
                    })
                }
            }
        }
    }

    // MARK: functions

    private func makeStressInfoText(stressLevel: StressLevel, comment: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Circle()
                .fill(stressLevel.color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            Text(stressLevel.displayName + ": " + String(comment))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    FaqStressMeasureInfoSheet()
        .environmentObject(SettingsViewModel.mock())
}
