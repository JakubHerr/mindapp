//
//  Month.swift
//  MindApp
//
//  Created by Michael Slavev on 18.04.2024.
//

import Foundation

struct Month: Equatable {
    var startDate: Date
    var endDate: Date {
        var components = Calendar.current.dateComponents([.year, .month], from: startDate)
        components.month! += 1
        components.day = 0
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components)!
    }

    mutating func next() {
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startDate) {
            startDate = nextMonth
        }
    }

    mutating func previous() {
        if let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: startDate) {
            startDate = prevMonth
        }
    }

    var formattedRange: String {
        let formatter = DateFormatter()
        let monthIndex = Calendar.current.component(.month, from: startDate) - 1
        let monthName = formatter.standaloneMonthSymbols[monthIndex]
        let year = Calendar.current.component(.year, from: startDate)

        return "\(monthName) \(year)"
    }
}
