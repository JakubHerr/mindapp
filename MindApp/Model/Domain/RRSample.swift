//
//  RRSample.swift
//  MindApp
//
//  Created by Michael Slavev on 19.05.2024.
//

import Foundation

struct RRSample: Decodable {
    let id = UUID()
    let date: Date
    let rrIntervals: [Double]
    let rmssd: Double
    let sdnn: Double

    enum CodingKeys: String, CodingKey {
        case date
        case rrIntervals
        case rmssd
        case sdnn
    }
}
