//
//  HealthDBManager.swift
//  MindApp
//
//  Created by Michael Slavev on 13.04.2024.
//

import Foundation

/// Manager class for the health data database, includes functions to manipulate and fetch data to and from the Supabase database
class HealthDBManager {
    static let shared = HealthDBManager()
    
    /// Function that adds new HRV data into Supabase
    /// - Parameters:
    ///   - date: Date of the new record
    ///   - hrvValue: Heart rate variability
    ///   - stressLevel: ``StressLevel`` describing the level of stress
    func addHRVData(date: Date, hrvValue: Double, stressLevel: StressLevel) async throws {
        do {
            let currentUser = try await supabase.auth.session.user

            let dateString = DateUtilities.getDBDateFormatString(from: date)

            // Check if the record already exists
            let result: [HRVDataPoint] = try await supabase.database
                .from("healthkit_hrv_data")
                .select()
                .eq("user_id", value: currentUser.id)
                .eq("date", value: dateString)
                .execute()
                .value

            // Insert if doesnt exist
            if result.count == 0 {
                try await supabase.database
                    .from("healthkit_hrv_data")
                    .insert(
                        HRVDataPointInsert(
                            userId: currentUser.id,
                            date: date,
                            value: hrvValue.rounded(.towardZero),
                            stressLevel: stressLevel
                        ))
                    .execute()
            }
        } catch {
            Logger.log(error.localizedDescription, .error)
        }
    }
    
    /// Fetches HRV data points from Supabase
    /// - Parameters:
    ///   - startDate: Date the HRV data points should start from
    ///   - endDate: Date the HRV data points should end on
    /// - Returns: Array of ``HRVDataPoint`` containing all the found values within the specified date range
    func fetchHRVDataPoints(startDate: Date, endDate: Date) async throws -> [HRVDataPoint] {
        do {
            let currentUser = try await supabase.auth.session.user

            let startDateString = DateUtilities.getDBDateFormatString(from: startDate)
            let endDateString = DateUtilities.getDBDateFormatString(from: endDate)

            let result: [HRVDataPoint] = try await supabase.database
                .from("healthkit_hrv_data")
                .select()
                .eq("user_id", value: currentUser.id)
                .gte("date", value: startDateString)
                .lte("date", value: endDateString)
                .order("date", ascending: true)
                .execute()
                .value

            return result
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }
}
