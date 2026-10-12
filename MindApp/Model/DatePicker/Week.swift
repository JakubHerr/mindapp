//
//  Week.swift
//  MindApp
//
//  Created by Michael Slavev on 18.04.2024.
//

import Foundation

struct Week: Equatable {
    var startDate: Date
    var endDate: Date {
        guard let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startDate) else {
            return startDate
        }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: endOfWeek)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components) ?? endOfWeek
    }

    mutating func next() {
        if let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate) {
            startDate = nextWeek
        }
    }

    mutating func previous() {
        if let prevWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startDate) {
            startDate = prevWeek
        }
    }

    var formattedRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
