//
//  DateData.swift
//  MindApp
//
//  Created by Michael Slavev on 27.04.2024.
//

import Foundation

struct DayData: Identifiable {
    var id = UUID()
    let date: Date
    let hrvValue: Double
    let stressLevel: StressLevel
    let mindfulnessDone: Bool
}
