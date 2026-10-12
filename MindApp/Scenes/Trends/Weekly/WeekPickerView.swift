//
//  WeekPickerView.swift
//  MindApp
//
//  Created by Michael Slavev on 18.04.2024.
//

import SwiftUI

struct WeekPickerView: View {
    @EnvironmentObject var viewModel: WeekPickerViewModel

    // MARK: View building

    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await viewModel.goToPreviousWeek()
                }
            }) {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(Color.appButtonMain)

            ZStack {
                Text(viewModel.currentWeek.formattedRange)
                    .font(.appSenBody)
                    .foregroundColor(.appTextDark)
                    .transition(.opacity)
                    .id(viewModel.currentWeek.startDate) // Change the ID to force the animation on update
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            Button(action: {
                Task {
                    await viewModel.goToNextWeek()
                }
            }) {
                Image(systemName: "chevron.right")
            }
            .foregroundColor(Color.appButtonMain)
            .disabled(viewModel.isNextWeekInFuture)
        }
        .animation(.default, value: viewModel.currentWeek)
    }
}

#Preview {
    WeekPickerView()
        .environmentObject(WeekPickerViewModel.mock())
}
