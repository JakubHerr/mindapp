//
//  LatestDataView.swift
//  MindApp
//
//  Created by Michael Slavev on 28.04.2024.
//

import SwiftUI

/// View showing the latest data summary
/// > Important: Needs to get ``HealthkitViewModel`` as an environmentObject in order to function
///
/// Example usage:
/// ```swift
/// let hkvm: HealthkitViewModel = HealthkitViewModel()
/// ...
/// LatestDataView()
///     .environmentObject(hkvm)
/// ```
struct LatestDataView: View {
    @EnvironmentObject var healthkitViewModel: HealthkitViewModel

    let hrvLabel = NSLocalizedString("dailyview_section_latest_readings_hrv_label", comment: "HRV label")
    let hrLabel = NSLocalizedString("dailyview_section_latest_readings_hr_label", comment: "HR label")
    let rhrLabel = NSLocalizedString("dailyview_section_latest_readings_rhr_label", comment: "RHR label")
    let hrv30Label = NSLocalizedString("dailyview_section_latest_readings_hrv30_label", comment: "HRV30 label")
    let rhr30Label = NSLocalizedString("dailyview_section_latest_readings_rhr30_label", comment: "RHR30 label")
    let noDataLabel = NSLocalizedString("noData_label", comment: "No data label")

    // MARK: View building

    var body: some View {
        HStack {
            makeInfoRow(title: hrvLabel, value: healthkitViewModel.latestSdnnHRV, unit: "ms")

            RoundedRectangle(cornerRadius: 5)
                .fill(Color.appBackgroundGradientTop)
                .frame(width: 2)

            makeInfoRow(title: hrLabel, value: healthkitViewModel.latestHR, unit: "BPM")

            RoundedRectangle(cornerRadius: 5)
                .fill(Color.appBackgroundGradientTop)
                .frame(width: 2)

            makeInfoRow(title: rhrLabel, value: healthkitViewModel.latestRHR, unit: "BPM")
        }

        RoundedRectangle(cornerRadius: 5)
            .fill(Color.appBackgroundGradientTop)
            .frame(height: 2)

        HStack {
            makeInfoRow(title: hrv30Label, value: healthkitViewModel.averageHRV30.averageRMSSD, unit: "ms")

            RoundedRectangle(cornerRadius: 5)
                .fill(Color.appBackgroundGradientTop)
                .frame(width: 2)

            makeInfoRow(title: rhr30Label, value: healthkitViewModel.averageRHR30, unit: "BPM")
        }
    }

    // MARK: Functions

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
    LatestDataView()
        .environmentObject(HealthkitViewModel.mock())
}
