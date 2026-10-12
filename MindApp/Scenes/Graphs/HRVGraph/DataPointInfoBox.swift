//
//  DataPointInfoBox.swift
//  MindApp
//
//  Created by Michael Slavev on 09.04.2024.
//

import SwiftUI

struct DataPointInfoBox: View {
    var dataPoint: HRVDataPoint

    let timeLabel = NSLocalizedString("graph_infobox_label_time", comment: "Time label")
    let hrvSdnnLabel = NSLocalizedString("graph_infobox_label_hrv_sdnn", comment: "HRV SDNN Label")
    let hrvRmssdLabel = NSLocalizedString("graph_infobox_label_hrv_rmssd", comment: "HRV rMSSD Label")
    let stressLabel = NSLocalizedString("graph_infobox_label_stress", comment: "Stress label")

    // MARK: View building

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(timeLabel): \(DateFormatter.shortTime.string(from: dataPoint.date))")
                .bold()
            Text("\(hrvRmssdLabel): \(dataPoint.rmssdHrv, specifier: "%.0f")")
            Text("\(hrvSdnnLabel): \(dataPoint.sdnnHrv, specifier: "%.0f")")
            Text("\(stressLabel): \(dataPoint.stressLevel.displayName)")
        }
        .padding()
        .background(.white.opacity(0.8))
        .foregroundColor(.black)
        .cornerRadius(8)
        .shadow(radius: 4)
        .font(.appSenBody)
    }
}

#Preview {
    DataPointInfoBox(dataPoint: HRVDataPoint(date: Date().addingTimeInterval(-3600 * 24), sdnnHrv: 70, rmssdHrv: 70, stressLevel: .AtPeace))
}
