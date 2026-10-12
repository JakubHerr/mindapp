//
//  HRVGraphView.swift
//  MindApp
//
//  Created by Michael Slavev on 04.04.2024.
//

import Charts
import SwiftUI

extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

struct HRVGraphView: View {
    @EnvironmentObject var viewModel: HealthkitViewModel
    @State private var selectedIndex: Int? = nil

    var dataPoints: [HRVDataPoint]
    var mindfullPoints: [MindfulDataPoint]

    init(dataPoints: [HRVDataPoint], mindfullPoints: [MindfulDataPoint]) {
        self.dataPoints = dataPoints
        self.mindfullPoints = mindfullPoints
    }

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
            VStack(alignment: .center) {
                // MARK: Chart

                Chart {
                    ForEach(dataPoints.indices, id: \.self) { index in
                        let dataPoint = dataPoints[index]
                        LineMark(
                            x: .value("hrv_stress_graph_time", dataPoint.date, unit: .minute),
                            y: .value("hrv_stress_graph_", dataPoint.rmssdHrv)
                        )
                        .foregroundStyle(index == selectedIndex ? dataPoint.stressLevel.color : Color.orange)
                        .symbol {
                            if index == selectedIndex {
                                ZStack {
                                    Circle()
                                        .strokeBorder(dataPoint.stressLevel.color, lineWidth: 4)
                                        .background(Circle().fill(Color.appBackgroundGradientBottom))
                                        .frame(width: 12, height: 12)
                                }
                            } else {
                                Circle()
                                    .fill(dataPoint.stressLevel.color)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }

                    // Add mindfulness session markers
                    ForEach(mindfullPoints, id: \.id) { point in
                        RuleMark(
                            x: .value("Mindfulness Session", point.startDate)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(Color.appGraphMindfulness)
                    }
                }
                .chartOverlay { chart in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let x = value.location.x - geometry[chart.plotAreaFrame].origin.x
                                        let y = value.location.y - geometry[chart.plotAreaFrame].origin.y
                                        updateSelectedIndex(x: x, y: y, chart: chart)
                                    }
                                    .onEnded { _ in selectedIndex = nil }
                            )
                    }
                }
                .overlay {
                    if let selectedIndex = selectedIndex, dataPoints.indices.contains(selectedIndex) {
                        DataPointInfoBox(dataPoint: dataPoints[selectedIndex])
                            .position(x: 175, y: 50)
                    }
                }

                // MARK: Graph info

                VStack {
                    HStack {
                        makeStressInfoText(stressLevel: .AtPeace)
                        Spacer()
                        makeStressInfoText(stressLevel: .Normal)
                    }
                    .padding(.leading, 55)
                    .padding(.trailing, 55)

                    HStack {
                        makeStressInfoText(stressLevel: .PayAttention)
                        Spacer()
                        makeStressInfoText(stressLevel: .Stressed)
                    }
                    .padding(.leading, 55)
                    .padding(.trailing, 55)
                }.frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Functions

    private func updateSelectedIndex(x: CGFloat, y: CGFloat, chart: ChartProxy) {
        let date: Date? = chart.value(atX: x, as: Date.self)
        guard let targetDate = date else {
            selectedIndex = nil
            return
        }

        let closestIndex = dataPoints.enumerated().min(by: { abs($0.1.date.timeIntervalSince(targetDate)) < abs($1.1.date.timeIntervalSince(targetDate)) })?.offset
        if selectedIndex != closestIndex {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        selectedIndex = closestIndex
    }

    private func makeStressInfoText(stressLevel: StressLevel) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(stressLevel.color)
                .frame(width: 8, height: 8)

            Text(stressLevel.displayName)
                .font(.appSenBody)
        }
    }
}

struct HRVGraphView_Previews: PreviewProvider {
    static var previews: some View {
        HRVGraphView(dataPoints: [], mindfullPoints: [])
            .environmentObject(HealthkitViewModel.mock())
    }
}
