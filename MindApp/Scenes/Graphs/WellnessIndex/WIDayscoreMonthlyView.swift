//
//  WIDayscoreMonthlyView.swift
//  MindApp
//
//  Created by Michael Slavev on 27.04.2024.
//

import Charts
import SwiftUI

struct WIDayscoreMonthlyView: View {
    @EnvironmentObject var viewModel: MonthPickerViewModel

    let avgHrvLabel = NSLocalizedString("wi_dayscore_avg_hrv_label", comment: "Average HRV label")
    let avgWeekdaysHrvLabel = NSLocalizedString("wi_dayscore_avg_weekday_hrv_label", comment: "Average HRV weekdays label")
    let avgWeekendsHrvLabel = NSLocalizedString("wi_dayscore_avg_weekend_hrv_label", comment: "Average HRV weekends label")
    let noDataLabel = NSLocalizedString("noData_label", comment: "No data label")

    // MARK: View Building

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.appButtonAccent))
        } else if !viewModel.isLoading && viewModel.hrvDataPoints.isEmpty {
            Text("hrv_stress_graph_nodata")
                .font(.headline)
                .foregroundColor(.white)
        } else {
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
                            viewModel.toggleDayscoreInfoSheet()
                        }
                }
                .padding(.bottom, 10)

                // MARK: Graph

                Chart {
                    ForEach(viewModel.weekdaysData, id: \.date) { dayData in
                        BarMark(
                            x: .value("Day", MonthPickerViewModel.dayOfWeekFormatter.string(from: dayData.date)),
                            y: .value("HRV", dayData.hrvValue)
                        )
                        .foregroundStyle(dayData.stressLevel.color)
                        .cornerRadius(10, style: .continuous)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .automatic) { value in
                        AxisValueLabel {
                            VStack {
                                if let dateString = value.as(String.self) {
                                    let mindfulnessDone = viewModel.weekdaysData.first(where: { MonthPickerViewModel.dayOfWeekFormatter.string(from: $0.date) == dateString })?.mindfulnessDone

                                    RoundedRectangle(cornerRadius: 2)
                                        .foregroundColor(mindfulnessDone! ? Color.appGraphMindfulness : Color.clear)
                                        .frame(height: 4)
                                        .frame(width: 5)
                                }

                                if let dateString = value.as(String.self), shouldDisplayLabel(date: MonthPickerViewModel.dayOfWeekFormatter.date(from: dateString) ?? Date()) {
                                    Text(dateString)
                                        .foregroundStyle(Color.white)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .automatic) { value in
                        AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue) ms")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                }

                Divider().overlay(Color.appBackgroundGradientTop)

                // MARK: Info

                HStack {
                    makeInfoRow(title: avgHrvLabel, value: viewModel.averageHRV, unit: "ms")
                }

                HStack {
                    makeInfoRow(title: avgWeekdaysHrvLabel, value: viewModel.averageHRVWeekdays, unit: "ms")

                    makeInfoRow(title: avgWeekendsHrvLabel, value: viewModel.averageHRVWeekends, unit: "ms")
                }
            }
            .sheet(isPresented: $viewModel.showingDayscoreInfoSheet) {
                WIDayscoreMonthlyInfoSheet()
                    .presentationDetents([.medium])
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: Functions

    private func shouldDisplayLabel(date: Date) -> Bool {
        let calendar = Calendar.current

        let dayOfMonth = calendar.component(.day, from: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        let lastDayOfMonth = range?.last ?? 0

        return dayOfMonth % 5 == 0 || dayOfMonth == 1 || dayOfMonth == lastDayOfMonth
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

#Preview {
    WIDayscoreMonthlyView()
        .environmentObject(MonthPickerViewModel.mock())
}
