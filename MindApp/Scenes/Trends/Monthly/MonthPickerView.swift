//
//  MonthPickerView.swift
//  MindApp
//
//  Created by Michael Slavev on 18.04.2024.
//

import SwiftUI

struct MonthPickerView: View {
    @EnvironmentObject var viewModel: MonthPickerViewModel

    // MARK: View building

    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await viewModel.goToPreviousMonth()
                }
            }) {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(Color.appButtonMain)

            Text(viewModel.currentMonth.formattedRange)
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(.appSenBody)
                .foregroundColor(.appTextDark)
                .transition(.opacity)
                .id(viewModel.currentMonth.startDate)

            Button(action: {
                Task {
                    await viewModel.goToNextMonth()
                }
            }) {
                Image(systemName: "chevron.right")
            }
            .foregroundColor(Color.appButtonMain)
            .disabled(viewModel.isNextMonthInFuture)
        }
        .animation(.default, value: viewModel.currentMonth)
    }
}

#Preview {
    MonthPickerView()
        .environmentObject(MonthPickerViewModel.mock())
}
