//
//  HKHRVEntry.swift
//  MindApp
//
//  Created by Michael Slavev on 07.04.2024.
//

import Foundation
import SwiftUI

enum StressLevel: String, Hashable, CaseIterable {
    case AtPeace
    case Normal
    case PayAttention
    case Stressed
    case Undefined
}

// MARK: DataPoint

struct HRVDataPoint: Decodable {
    let id = UUID()
    let date: Date
    let sdnnHrv: Double
    let rmssdHrv: Double
    let stressLevel: StressLevel

    enum CodingKeys: String, CodingKey {
        case date
        case sdnnHrv
        case rmssdHrv
        case stressLevel = "stress_level"
    }
}

struct HRVDataPointInsert: Encodable {
    let userId: UUID
    let date: Date
    let value: Double
    let stressLevel: StressLevel

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case date
        case value
        case stresLevel = "stress_level"
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(dateString, forKey: .date)
        try container.encode(value, forKey: .value)
        try container.encode(stressLevel.rawValue, forKey: .stresLevel)
        try container.encode(userId, forKey: .userId)
    }
}

// MARK: Conformances

extension HRVDataPoint: Equatable {}
extension HRVDataPoint: Identifiable {}
extension HRVDataPoint: Encodable {}

extension StressLevel: Encodable {}
extension StressLevel: Decodable {}

// MARK: Extensions

extension StressLevel {
    var color: Color {
        switch self {
        case .AtPeace:
            return .green
        case .Normal:
            return .blue
        case .PayAttention:
            return .orange
        case .Stressed:
            return .red
        case .Undefined:
            return .gray
        }
    }

    var displayName: String {
        switch self {
        case .AtPeace:
            return NSLocalizedString("stress_level_atpeace", comment: "At Peace")
        case .Normal:
            return NSLocalizedString("stress_level_normal", comment: "Normal")
        case .PayAttention:
            return NSLocalizedString("stress_level_payattention", comment: "Pay Attention")
        case .Stressed:
            return NSLocalizedString("stress_level_stressed", comment: "Stressed")
        case .Undefined:
            return NSLocalizedString("stress_level_undefined", comment: "Undefined")
        }
    }

    var numericValue: Int {
        switch self {
        case .AtPeace:
            return 1
        case .Normal:
            return 2
        case .PayAttention:
            return 3
        case .Stressed:
            return 4
        case .Undefined:
            return 0
        }
    }
}

// MARK: - Mock

#if DEBUG
extension HRVDataPoint {
    static let mock: HRVDataPoint = .init(
        date: Date().addingTimeInterval(-3600 * 24),
        sdnnHrv: 60,
        rmssdHrv: 53,
        stressLevel: .Normal
    )

    static let mocks: [HRVDataPoint] = (0 ... 15).map { offset in
        HRVDataPoint(
            date: Date().addingTimeInterval(-3600 * Double(24 - offset)),
            sdnnHrv: Double.random(in: 30 ... 80),
            rmssdHrv: Double.random(in: 30 ... 80),
            stressLevel: getRandomStressLevel()
        )
    }

    private static func getRandomStressLevel() -> StressLevel {
        let allStressLevels: [StressLevel] = [.AtPeace, .Normal, .PayAttention, .Stressed]
        return allStressLevels.randomElement() ?? .Normal
    }
}
#endif
