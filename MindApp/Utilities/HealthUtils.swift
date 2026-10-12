//
//  HealthUtils.swift
//  MindApp
//
//  Created by Michael Slavev on 02.05.2024.
//

import Foundation

enum HealthUtils {
    static func calculateRMSSD(rrIntervals: [Double]) throws -> Double {
        guard rrIntervals.count > 1 else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not enough RR intervals to calculate RMSSD"])
        }

        let differences = zip(rrIntervals.dropFirst(), rrIntervals).map { $0.0 - $0.1 }
        let squaredDifferences = differences.map { $0 * $0 }
        let meanOfSquaredDifferences = squaredDifferences.reduce(0, +) / Double(differences.count)
        let rMSSD = sqrt(meanOfSquaredDifferences)

        return rMSSD * 1000
    }

    static func calculateSDNN(rrIntervals: [Double]) throws -> Double {
        guard rrIntervals.count > 1 else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not enough RR intervals to calculate SDNN"])
        }

        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let sumOfSquaredDiffs = rrIntervals.reduce(0) { $0 + ($1 - mean) * ($1 - mean) }
        let sdnn = sqrt(sumOfSquaredDiffs / Double(rrIntervals.count - 1))

        return sdnn * 1000
    }

    static func calculateStressLevel(averageHRV30: Double, hrv: Double) -> StressLevel {
        let hrvThreshold = averageHRV30 * 0.075
        let hrvThresholdLower = averageHRV30 * 0.3

        switch hrv {
        case let value where value > (averageHRV30 + hrvThreshold):
            return .AtPeace
        case let value where value >= (averageHRV30 - hrvThreshold) && value <= (averageHRV30 + hrvThreshold):
            return .Normal
        case let value where value >= (averageHRV30 - hrvThresholdLower) && value < (averageHRV30 - hrvThreshold):
            return .PayAttention
        default:
            return .Stressed
        }
    }
}
