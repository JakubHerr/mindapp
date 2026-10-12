//
//  WeekPickerViewModel.swift
//  MindApp
//
//  Created by Michael Slavev on 18.04.2024.
//

import Foundation
import HealthKit

@MainActor
final class WeekPickerViewModel: ObservableObject {
    @Injected private var healthDBManager: HealthDBManager
    @Injected private var healthKitManager: HealthKitManager

    @Published var currentWeek: Week
    @Published var hrvDataPoints: [HRVDataPoint] = []
    @Published var mindfulnessDataPoints: [MindfulDataPoint] = []
    @Published var averageStressLevels: [[StressLevel?]] = []
    @Published var stressLevelCounts: [StressLevel: Int] = [:]
    @Published var weekdaysData: [DayData] = []

    @Published var averageHRV: Double = 0
    @Published var averageHRVWeekdays: Double = 0
    @Published var averageHRVWeekends: Double = 0
    @Published var minHRV: Double = 0
    @Published var maxHRV: Double = 0

    @Published var isLoading: Bool = false
    @Published var showingDayscoreInfoSheet: Bool = false
    @Published var showingTimeofdayInfoSheet: Bool = false

    let calendar = Calendar.current

    init() {
        let today = Date()
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        currentWeek = Week(startDate: startOfWeek)
    }

    func goToNextWeek() async {
        currentWeek.next()
        await fetchData()
    }

    func goToPreviousWeek() async {
        currentWeek.previous()
        await fetchData()
    }

    var isNextWeekInFuture: Bool {
        return currentWeek.endDate >= Date()
    }

    func toggleDayscoreInfoSheet() {
        showingDayscoreInfoSheet.toggle()
    }

    func toggleTimeofdayInfoSheet() {
        showingTimeofdayInfoSheet.toggle()
    }

    // MARK: Fetch data

    func fetchData() async {
        isLoading = true
        hrvDataPoints.removeAll()
        mindfulnessDataPoints.removeAll()

        await fetchMindfullData()

        minHRV = Double.greatestFiniteMagnitude
        maxHRV = -Double.greatestFiniteMagnitude

        var totalHRVWeekdays = 0.0
        var countWeekdays = 0
        var totalHRVWeekends = 0.0
        var countWeekends = 0

        do {
            let allSamples = try await healthKitManager.fetchHeartbeatSeriesSamples(
                from: currentWeek.startDate.adding(days: -30),
                to: currentWeek.endDate)

            var allRRIntervals: [RRSample] = []
            for sample in allSamples {
                let res = try await healthKitManager.fetchRRIntervals(from: sample)
                let rmssd = try HealthUtils.calculateRMSSD(rrIntervals: res)
                let sdnn = try HealthUtils.calculateRMSSD(rrIntervals: res)

                allRRIntervals.append(RRSample(date: sample.startDate, rrIntervals: res, rmssd: rmssd, sdnn: sdnn))
            }

            var date = currentWeek.startDate
            while date < currentWeek.endDate {
                let startDate30DaysBack = calendar.date(byAdding: .day, value: -30, to: date)!
                let samplesForLast30Days = allRRIntervals.filter { $0.date >= startDate30DaysBack && $0.date <= date }
                let averageHRV30: Double
                if !samplesForLast30Days.isEmpty {
                    let totalRMSSD = samplesForLast30Days.reduce(0.0) { $0 + $1.rmssd }
                    averageHRV30 = totalRMSSD / Double(samplesForLast30Days.count)
                } else {
                    averageHRV30 = 0.0
                }

                let samplesForThisDay = allRRIntervals.filter { $0.date >= date && $0.date <= date.adding(days: 1) }

                for daySample in samplesForThisDay {
                    let stressLevel = HealthUtils.calculateStressLevel(averageHRV30: averageHRV30, hrv: daySample.rmssd)

                    let hrvDataPoint = HRVDataPoint(date: daySample.date, sdnnHrv: daySample.sdnn, rmssdHrv: daySample.rmssd, stressLevel: stressLevel)

                    hrvDataPoints.append(hrvDataPoint)

                    // Accumulate HRV based on weekday or weekend
                    if calendar.isDateInWeekend(daySample.date) {
                        totalHRVWeekends += daySample.rmssd
                        countWeekends += 1
                    } else {
                        totalHRVWeekdays += daySample.rmssd
                        countWeekdays += 1
                    }

                    // Update min and max HRV values
                    minHRV = min(minHRV, daySample.rmssd)
                    maxHRV = max(maxHRV, daySample.rmssd)
                }

                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }

        } catch {
            Logger.log("whoopsie")
        }

        // Calculate averages for whole week, weekdays and weekends
        averageHRVWeekdays = countWeekdays > 0 ? totalHRVWeekdays / Double(countWeekdays) : 0
        averageHRVWeekends = countWeekends > 0 ? totalHRVWeekends / Double(countWeekends) : 0
        if !hrvDataPoints.isEmpty {
            averageHRV = hrvDataPoints.map { $0.sdnnHrv }.reduce(0, +) / Double(hrvDataPoints.count)
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.calculateWeekdaysData() }
            group.addTask { await self.calculateStressLevelCounts() }
            group.addTask { await self.calculateAverageStressLevels() }
        }

        isLoading = false
    }

    func fetchMindfullData() async {
        do {
            let mindfulSamples = try await healthKitManager.fetchMindfulnessMinutes(from: currentWeek.startDate, to: currentWeek.endDate)
            var tempMindfulnessDataPoints = [MindfulDataPoint]()

            for sample in mindfulSamples {
                if let metadata = sample.metadata,
                   let sourceApp = metadata["SourceApp"] as? String,
                   let category = metadata["Category"] as? String,
                   let type = metadata["Type"] as? String,
                   let feeling = metadata["Feeling"] as? String
                {
                    let mindPoint = MindfulDataPoint(startDate: sample.startDate, endDate: sample.endDate, sourceApp: sourceApp, category: category, type: type, feeling: feeling)
                    tempMindfulnessDataPoints.append(mindPoint)
                }
                else if let metadata = sample.metadata,
                        let _ = metadata["SourceApp"] as? String
                {
                    //Do nothing
                }
                else {
                    Logger.log("Incomplete metadata for sample starting at \(sample.startDate)")
                }
            }

            mindfulnessDataPoints = tempMindfulnessDataPoints
        } catch {
            Logger.log("Failed to fetch mindfulness samples: \(error)")
        }
    }

    // MARK: Day Score

    private func calculateWeekdaysData() async {
        var daysRange: [Date] = []
        var date = currentWeek.startDate

        while date <= currentWeek.endDate {
            daysRange.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        let groupedHRVData = Dictionary(grouping: hrvDataPoints) { dataPoint in
            calendar.startOfDay(for: dataPoint.date)
        }

        let mindfulnessDays = Set(mindfulnessDataPoints.map { calendar.startOfDay(for: $0.startDate) })

        weekdaysData = daysRange.map { date -> DayData in
            let mindfulnessDone = mindfulnessDays.contains(date)

            if let values = groupedHRVData[date] {
                let total = values.reduce(0.0) { $0 + $1.rmssdHrv }
                let average = total / Double(values.count)
                let mostCommonStressLevel = calculateMostCommonStressLevel(for: values)
                return DayData(date: date, hrvValue: average, stressLevel: mostCommonStressLevel, mindfulnessDone: mindfulnessDone)
            } else {
                return DayData(date: date, hrvValue: 0, stressLevel: .Undefined, mindfulnessDone: mindfulnessDone)
            }
        }
    }

    private func calculateMostCommonStressLevel(for values: [HRVDataPoint]) -> StressLevel {
        let priorityOrder: [StressLevel] = [.Stressed, .PayAttention, .Normal, .AtPeace, .Undefined]

        let counts = values.reduce(into: [:]) { counts, hrvDataPoint in
            counts[hrvDataPoint.stressLevel, default: 0] += 1
        }

        let mostCommon = counts.max { a, b in
            if a.value == b.value {
                return priorityOrder.firstIndex(of: a.key)! < priorityOrder.firstIndex(of: b.key)!
            }
            return a.value < b.value
        }

        return mostCommon?.key ?? .Undefined
    }

    static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()

    // MARK: Breakdown

    private func calculateStressLevelCounts() async {
        stressLevelCounts = hrvDataPoints.reduce(into: [:]) { counts, dataPoint in
            counts[dataPoint.stressLevel, default: 0] += 1
        }
    }

    // MARK: Time of day

    var daysInPeriod: Int {
        return 7
    }

    private func calculateAverageStressLevels() async {
        let days = Calendar.current.dateComponents([.day], from: calendar.startOfDay(for: currentWeek.startDate), to: calendar.startOfDay(for: currentWeek.endDate)).day ?? 0
        var results = Array(repeating: Array(repeating: nil as StressLevel?, count: 24), count: days + 1)

        var groupedDataPoints = [Int: [Int: [HRVDataPoint]]]()

        for dataPoint in hrvDataPoints {
            let dayOffset = Calendar.current.dateComponents([.day], from: calendar.startOfDay(for: currentWeek.startDate), to: calendar.startOfDay(for: dataPoint.date)).day!
            groupedDataPoints[dayOffset, default: [Int: [HRVDataPoint]]()][Calendar.current.component(.hour, from: dataPoint.date), default: [HRVDataPoint]()].append(dataPoint)
        }

        for (day, hours) in groupedDataPoints {
            for (hour, points) in hours {
                let mostCommonStressLevel = calculateMostCommonStressLevel(for: points)
                if day >= 0 && day < results.count {
                    results[day][hour] = mostCommonStressLevel
                }
            }
        }

        averageStressLevels = results
    }
    
    
    static func mock() -> WeekPickerViewModel {
        return WeekPickerViewModel()
    }
}
