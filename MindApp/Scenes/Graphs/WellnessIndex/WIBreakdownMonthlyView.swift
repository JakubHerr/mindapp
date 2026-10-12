//
//  WIBreakdownMonthlyView.swift
//  MindApp
//
//  Created by Michael Slavev on 27.04.2024.
//

import Charts
import SwiftUI

struct WIBreakdownMonthlyView: View {
    @EnvironmentObject var viewModel: MonthPickerViewModel

    // MARK: View building

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
                HStack {
                    // MARK: Textual info breakdown

                    VStack {
                        HStack {
                            makeInfoRow(title: "Total", value: viewModel.hrvDataPoints.count, stressLevel: nil)
                        }

                        Spacer()
                        Divider().overlay(Color.appBackgroundGradientTop)
                        Spacer()

                        HStack {
                            makeInfoRow(
                                title: StressLevel.AtPeace.displayName,
                                value: viewModel.stressLevelCounts[.AtPeace] ?? 0,
                                stressLevel: StressLevel.AtPeace
                            )
                            makeInfoRow(
                                title: StressLevel.Normal.displayName,
                                value: viewModel.stressLevelCounts[.Normal] ?? 0,
                                stressLevel: StressLevel.Normal
                            )
                        }

                        Spacer()

                        HStack {
                            makeInfoRow(
                                title: StressLevel.PayAttention.displayName,
                                value: viewModel.stressLevelCounts[.PayAttention] ?? 0,
                                stressLevel: StressLevel.PayAttention
                            )
                            makeInfoRow(
                                title: StressLevel.Stressed.displayName,
                                value: viewModel.stressLevelCounts[.Stressed] ?? 0,
                                stressLevel: StressLevel.Stressed
                            )
                        }
                    }

                    Spacer()

                    // MARK: Graph breakdown

                    VStack {
                        Chart {
                            ForEach([StressLevel.Stressed, StressLevel.PayAttention, StressLevel.Normal, StressLevel.AtPeace], id: \.self) { level in
                                let count = viewModel.hrvDataPoints.filter { $0.stressLevel == level }.count
                                if count > 0 {
                                    BarMark(
                                        x: .value("Stress Level", "All"),
                                        y: .value("Count", count)
                                    )
                                    .foregroundStyle(level.color)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(width: 70)
                    }
                }
            }
        }
    }

    // MARK: Functions

    private func makeInfoRow(title: String, value: Int, stressLevel: StressLevel?) -> some View {
        HStack {
            if stressLevel != nil {
                RoundedRectangle(cornerRadius: 5)
                    .fill(stressLevel?.color ?? .gray)
                    .frame(width: 4)
            }

            VStack(spacing: 1) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.appSenBody)

                Text("\(value)x")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                    .font(.appSenTitle)
            }
        }
        .padding(.top, 5)
    }
}

#Preview {
    WIBreakdownMonthlyView()
        .environmentObject(MonthPickerViewModel.mock())
}
