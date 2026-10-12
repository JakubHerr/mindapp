//
//  WIDayscoreMonthlyInfoSheet.swift
//  MindApp
//
//  Created by Michael Slavev on 04.05.2024.
//

import SwiftUI

struct WIDayscoreMonthlyInfoSheet: View {
    @EnvironmentObject var viewModel: MonthPickerViewModel

    let infoHeaderLabel = NSLocalizedString("infosheet_wi_dayscore_header", comment: "Header of dayscore info section")
    let infoTextLabel = NSLocalizedString("infosheet_wi_dayscore_text", comment: "Text of dayscore info section")

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: viewModel.toggleDayscoreInfoSheet)

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
    WIDayscoreMonthlyInfoSheet()
        .environmentObject(MonthPickerViewModel.mock())
}
