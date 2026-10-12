//
//  MindfullDataPoint.swift
//  MindApp
//
//  Created by Michael Slavev on 18.05.2024.
//

import Foundation

// MARK: Mindfulness data point

struct MindfulDataPoint: Identifiable, Decodable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let sourceApp: String
    let category: String
    let type: String
    let feeling: String

    enum CodingKeys: String, CodingKey {
        case startDate
        case endDate
        case sourceApp
        case category
        case type
        case feeling
    }

    var duration: String {
        let durationInSeconds = Int(endDate.timeIntervalSince(startDate))
        let minutes = durationInSeconds / 60
        let seconds = durationInSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }

    var feelingScore: Int {
        switch feeling.lowercased() {
        case "better":
            return 1
        case "same":
            return 0
        case "worse":
            return -1
        default:
            return 0
        }
    }
}
