//
//  WITimeOfDayMonthlyInfoSheet.swift
//  MindApp
//
//  Created by Michael Slavev on 04.05.2024.
//

import SwiftUI

struct WITimeOfDayMonthlyInfoSheet: View {
    @EnvironmentObject var dailyViewModel: MonthPickerViewModel

    let infoHeaderLabel = NSLocalizedString("infosheet_wi_timeofday_header", comment: "Header of time of day info section")
    let infoTextLabel = NSLocalizedString("infosheet_wi_timeofday_text", comment: "Text of time of day info section")

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: dailyViewModel.toggleTimeofdayInfoSheet)

                // MARK: Content

                ScrollView {
                    SheetInfoSectionView(sectionHeaderText: infoHeaderLabel, content: {
                        VStack {
                            Text(infoTextLabel)
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
    WITimeOfDayMonthlyInfoSheet()
        .environmentObject(MonthPickerViewModel.mock())
}
