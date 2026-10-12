//
//  DatabaseDates.swift
//  MindApp
//
//  Created by Michael Slavev on 16.04.2024.
//

import Foundation

enum DateUtilities {
    static var iso8601Formatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }

    static func getDBDateFormatString(from date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }

    static func parseDate(from dateString: String) -> Date? {
        return iso8601Formatter.date(from: dateString)
    }
}
