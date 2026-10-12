//
//  DailyGraphSheetView.swift
//  MindApp
//
//  Created by Michael Slavev on 02.05.2024.
//

import SwiftUI

struct DailyGraphSheetView: View {
    @EnvironmentObject var dailyViewModel: DailyViewModel

    let headerLabel = NSLocalizedString("infosheet_daily_header", comment: "Header label")
    let textLabel = NSLocalizedString("infosheet_daily_text", comment: "Text label")
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
                CustomSheetHeaderView(withBackButton: true, action: dailyViewModel.toggleInfoSheet)

                // MARK: Content

                ScrollView {
                    SheetInfoSectionView(sectionHeaderText: headerLabel, content: {
                        VStack {
                            Text(textLabel)
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
    DailyGraphSheetView()
        .environmentObject(DailyViewModel.mock())
}
