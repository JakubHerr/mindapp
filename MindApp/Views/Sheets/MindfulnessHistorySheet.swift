//
//  MindfulnessHistorySheet.swift
//  MindApp
//
//  Created by Michael Slavev on 30.05.2024.
//

import SwiftUI

struct MindfulnessHistorySheet: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel

    init() {
        UISegmentedControl.appearance().backgroundColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: profileViewModel.toggleMindfulHistorySheet)

                // MARK: Content

                ScrollView {
                    ForEach(profileViewModel.getGroupedMindfulnessDataPoints(), id: \.date) { date, dataPoints in
                        if !dataPoints.isEmpty {
                            SheetInfoSectionView(sectionHeaderText: dateFormatter.string(from: date)) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, dataPoint in
                                        if let activity = profileViewModel.getActivityByName(dataPoint.type) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: activity.imageUrl)
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(Color.green)

                                                    VStack(alignment: .leading) {
                                                        Text(activity.localization.first?.title ?? "Unknown")
                                                            .font(.appSenBody)
                                                            .bold()

                                                        HStack {
                                                            Text("mind_session_feeling")
                                                                .font(.appSenBody)

                                                            Text(iconForFeeling(dataPoint.feeling))
                                                        }

                                                        HStack {
                                                            Text("mind_session_start_time")
                                                                .font(.appSenBody)

                                                            Text(dataPoint.formattedStartTime)
                                                        }

                                                        HStack {
                                                            Text("mind_session_duration")
                                                                .font(.appSenBody)

                                                            Text("\(dataPoint.duration) min")
                                                        }
                                                    }

                                                    Spacer()
                                                }

                                                if index != dataPoints.count - 1 {
                                                    Divider().background(Color.green)
                                                }
                                            }
                                            .background(Color.appBackgroundGreenMain)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func iconForFeeling(_ feeling: String) -> String {
        switch feeling.lowercased() {
        case "better":
            return "😊"
        case "same":
            return "😐"
        case "worse":
            return "😟"
        default:
            return "❓"
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    MindfulnessHistorySheet()
        .environmentObject(ProfileViewModel.mock())
}
