//
//  TrendsMonthlyView.swift
//  MindApp
//
//  Created by Michael Slavev on 17.04.2024.
//

import SwiftUI

struct TrendsMonthlyView: View {
    @EnvironmentObject var viewModel: MonthPickerViewModel

    // MARK: View building

    var body: some View {
        LazyVStack {
            // MARK: DatePicker

            MonthPickerView()
                .padding()
                .padding([.horizontal])

            // MARK: Dayscore Average

            Section(header:
                Text("trends_section_dayscore_header")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.appSenBody)
                    .foregroundColor(.appTextDark)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

            ) {
                VStack {
                    WIDayscoreMonthlyView()
                        .frame(height: self.viewModel.hrvDataPoints.isEmpty ? 75 : nil)
                        .frame(minHeight: self.viewModel.hrvDataPoints.isEmpty ? nil : 350, maxHeight: .infinity)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.appBackgroundGradientBottom)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding([.horizontal])
            }

            // MARK: Score breakdown

            Section(header:
                Text("trends_section_breakdown_header")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.appSenBody)
                    .foregroundColor(.appTextDark)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

            ) {
                VStack {
                    VStack {
                        WIBreakdownMonthlyView()
                            .frame(height: self.viewModel.hrvDataPoints.isEmpty ? 75 : nil)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.appBackgroundGradientBottom)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding([.horizontal])
            }

            // MARK: Time of day

            Section(header:
                Text("trends_section_timeofday_header")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.appSenBody)
                    .foregroundColor(.appTextDark)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: -5, trailing: 0))

            ) {
                VStack {
                    WITimeOfDayMonthlyView()
                        .frame(height: self.viewModel.hrvDataPoints.isEmpty ? 75 : nil)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.appBackgroundGradientBottom)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding([.horizontal])
            }
        }
    }
}

#Preview {
    TrendsMonthlyView()
        .environmentObject(MonthPickerViewModel.mock())
}
