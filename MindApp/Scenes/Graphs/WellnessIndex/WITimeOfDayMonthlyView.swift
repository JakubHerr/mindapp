//
//  WITimeOfDayMonthlyView.swift
//  MindApp
//
//  Created by Michael Slavev on 27.04.2024.
//

import SwiftUI

struct WITimeOfDayMonthlyView: View {
    @EnvironmentObject var viewModel: MonthPickerViewModel

    let minHrvLabel = NSLocalizedString("wi_timeofday_min_hrv_label", comment: "Min HRV label")
    let maxHrvLabel = NSLocalizedString("wi_timeofday_max_hrv_label", comment: "Max HRV label")
    let noDataLabel = NSLocalizedString("noData_label", comment: "No data label")

    // MARK: View building

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.appButtonAccent))
            } else if viewModel.hrvDataPoints.isEmpty {
                Text("hrv_stress_graph_nodata")
                    .font(.headline)
                    .foregroundColor(.white)
            } else {
                self.GraphContentView
                    .sheet(isPresented: $viewModel.showingTimeofdayInfoSheet) {
                        WITimeOfDayMonthlyInfoSheet()
                            .presentationDetents([.medium])
                            .environmentObject(viewModel)
                    }
            }
        }
    }

    // MARK: Functions

    private var GraphContentView: some View {
        VStack {
            // MARK: About graph

            HStack {
                Spacer()
                Image(systemName: "info.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        viewModel.toggleTimeofdayInfoSheet()
                    }
            }
            .padding(.bottom, 10)

            // MARK: Graph

            HStack {
                // Dots grid
                VStack(spacing: 4) {
                    ForEach(0..<self.viewModel.daysInPeriod, id: \.self) { day in
                        LazyHStack(spacing: 2) {
                            // Y-Axis label
                            Text(viewModel.formattedDayLabel(for: day))
                                .font(.caption)
                                .frame(width: 20, alignment: .leading)
                                .padding(.trailing, 2)

                            Spacer()

                            ForEach(0..<24, id: \.self) { hour in
                                VStack(spacing: 2) {
                                    // Stress bar
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(self.viewModel.averageStressLevels[day][hour]?.color ?? Color.gray)
                                        .frame(width: 10, height: 7)

                                    // Mindfullness bar
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(viewModel.mindfulnessColor(day: day, hour: hour))
                                        .frame(width: 10, height: 3)
                                }
                            }
                        }
                    }
                }
            }
            // X-Axis label
            HStack {
                Spacer()

                ForEach(0..<24, id: \.self) { hour in
                    if hour % 4 == 0 {
                        Text("\(hour)")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }

                Text("23")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .padding(.leading, 17)

            Divider().overlay(Color.appBackgroundGradientTop)

            // MARK: Info

            VStack {
                HStack {
                    makeInfoRow(title: minHrvLabel, value: viewModel.minHRV, unit: "ms")

                    makeInfoRow(title: maxHrvLabel, value: viewModel.maxHRV, unit: "ms")
                }
            }
        }
    }

    private func makeInfoRow(title: String, value: Double?, unit: String) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.caption)

            if let val = value {
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text("\(val, specifier: "%.0f")")
                        .fontWeight(.bold)
                        .font(.appSenTitle)

                    Text(unit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.appSenBody)
                }

            } else {
                HStack {
                    Text(noDataLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.appSenBody)
                }
            }
        }
        .padding(.top, 5)
    }
}

extension MonthPickerViewModel {
    func formattedDayLabel(for index: Int) -> String {
        let dayDate = Calendar.current.date(byAdding: .day, value: index, to: currentMonth.startDate)!
        return MonthPickerViewModel.dayOfWeekFormatter.string(from: dayDate)
    }

    func mindfulnessColor(day: Int, hour: Int) -> Color {
        let dayDate = Calendar.current.date(byAdding: .day, value: day, to: currentMonth.startDate)!
        let startOfHour = Calendar.current.date(byAdding: .hour, value: hour, to: dayDate)!

        return mindfulnessDataPoints.contains(where: { Calendar.current.isDate($0.startDate, inSameDayAs: startOfHour) && Calendar.current.component(.hour, from: $0.startDate) == hour }) ? Color.appGraphMindfulness : Color.gray
    }
}

#Preview {
    WITimeOfDayMonthlyView()
        .environmentObject(MonthPickerViewModel.mock())
}
