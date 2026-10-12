//
//  ProfileViewModel.swift
//  MindApp
//
//  Created by Michael Slavev on 28.05.2024.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Injected private var healthKitManager: HealthKitManager
    @Injected private var mindfulnessDbManager: MindfulnessDBManager

    @Published var showingMindfulHistorySheet: Bool = false
    @Published var partialActivities: [PartialActivity] = []
    @Published var partialActivitiesAllLocales: [PartialActivity] = []

    @Published var currentXP: Int = 0
    @Published var currentLevel: Int = 1
    @Published var xpForNextLevel: Int = 1000

    @Published var totalMindfulnessSeconds: Int = 0
    @Published var currentStreak: Int = 0
    @Published var topStreak: Int = 0
    @Published var perfectWeekCount: Int = 0
    @Published var perfectMonthCount: Int = 0

    private var mindfulnessDataPoints: [MindfulDataPoint] = []

    init() {
        fetchMindfulnessStatistics()
    }

    // MARK: Sheet toggles

    func toggleMindfulHistorySheet() {
        showingMindfulHistorySheet.toggle()
    }

    // MARK: Functions

    func fetchMindfulnessStatistics() {
        Task {
            do {
                try await fetchMindfulnessDataPoints()

                totalMindfulnessSeconds = calculateTotalMindfulnessSeconds()

                let streaks = calculateMindfulnessStreaks()
                currentStreak = streaks.currentStreak
                topStreak = streaks.topStreak
                perfectWeekCount = streaks.perfectWeekCount
                perfectMonthCount = streaks.perfectMonthCount

                calculateExperiencePoints()
            } catch {
                print("Error fetching mindful statistics: \(error)")
            }
        }
    }

    private func fetchMindfulnessDataPoints() async throws {
        let startDate = Date.distantPast
        let endDate = Date()

        let mindfulSamples = try await healthKitManager.fetchMindfulnessMinutes(from: startDate, to: endDate)
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
    }

    private func calculateTotalMindfulnessSeconds() -> Int {
        return mindfulnessDataPoints.reduce(0) { $0 + Int($1.endDate.timeIntervalSince($1.startDate)) }
    }

    private func calculateMindfulnessStreaks() -> (currentStreak: Int, topStreak: Int, perfectWeekCount: Int, perfectMonthCount: Int) {
        guard !mindfulnessDataPoints.isEmpty else {
            return (0, 0, 0, 0)
        }

        var currentStreak = 0
        var topStreak = 0
        var perfectWeekCount = 0
        var perfectMonthCount = 0

        var streak = 0
        var lastSessionDate: Date?
        var currentWeek = Set<Int>()
        var currentMonth = Set<Int>()

        var weekTracker = [Int: Set<Int>]()
        var monthTracker = [Int: Set<Int>]()

        for point in mindfulnessDataPoints {
            let sessionDate = Calendar.current.startOfDay(for: point.startDate)
            let weekOfYear = Calendar.current.component(.weekOfYear, from: sessionDate)
            let monthOfYear = Calendar.current.component(.month, from: sessionDate)

            if let lastDate = lastSessionDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: lastDate, to: sessionDate).day!

                if daysBetween == 1 {
                    streak += 1
                } else if daysBetween > 1 {
                    if streak > topStreak {
                        topStreak = streak
                    }
                    streak = 1
                }
            } else {
                streak = 1
            }

            lastSessionDate = sessionDate
            currentWeek.insert(Calendar.current.component(.weekday, from: sessionDate))
            currentMonth.insert(Calendar.current.component(.day, from: sessionDate))

            if weekTracker[weekOfYear] == nil {
                weekTracker[weekOfYear] = Set<Int>()
            }
            weekTracker[weekOfYear]?.insert(Calendar.current.component(.weekday, from: sessionDate))

            if monthTracker[monthOfYear] == nil {
                monthTracker[monthOfYear] = Set<Int>()
            }
            monthTracker[monthOfYear]?.insert(Calendar.current.component(.day, from: sessionDate))
        }

        if streak > topStreak {
            topStreak = streak
        }

        currentStreak = streak

        for week in weekTracker.values {
            if week.count == 7 {
                perfectWeekCount += 1
            }
        }

        for month in monthTracker.values {
            let totalDaysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())!.count
            if month.count == totalDaysInMonth {
                perfectMonthCount += 1
            }
        }

        return (currentStreak, topStreak, perfectWeekCount, perfectMonthCount)
    }

    private func calculateExperiencePoints() {
        let xpPerSecond = 100.0 / 60.0
        let totalXP = Int(Double(totalMindfulnessSeconds) * xpPerSecond)
        var remainingXP = totalXP
        var level = 1

        while remainingXP > 0 {
            let xpNeededForNextLevel: Int
            if level < 5 {
                xpNeededForNextLevel = 1000
            } else if level < 10 {
                xpNeededForNextLevel = 2000
            } else {
                xpNeededForNextLevel = 5000
            }

            if remainingXP >= xpNeededForNextLevel {
                remainingXP -= xpNeededForNextLevel
                level += 1
            } else {
                xpForNextLevel = xpNeededForNextLevel
                break
            }
        }

        currentLevel = level
        currentXP = remainingXP
    }

    func getGroupedMindfulnessDataPoints() -> [(date: Date, dataPoints: [MindfulDataPoint])] {
        var groupedData = [Date: [MindfulDataPoint]]()

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        for dataPoint in mindfulnessDataPoints {
            let dateKey = Calendar.current.startOfDay(for: dataPoint.endDate)
            if groupedData[dateKey] == nil {
                groupedData[dateKey] = []
            }
            groupedData[dateKey]?.append(dataPoint)
        }

        for key in groupedData.keys {
            groupedData[key]?.sort(by: { $0.endDate > $1.endDate })
        }

        let sortedGroupedData = groupedData.map { (date: $0.key, dataPoints: $0.value) }.sorted { $0.date > $1.date }
        return sortedGroupedData
    }

    func fetchPartialActivities() async {
        do {
            partialActivities = try await mindfulnessDbManager.fetchPartialActivities()
        } catch {
            Logger.log("Failed to fetch Mindfulness activity data from DB: \(error)")
        }
    }

    func fetchPartialActivitiesAllLocales() async {
        do {
            partialActivitiesAllLocales = try await mindfulnessDbManager.fetchPartialActivitiesAllLocales()
        } catch {
            Logger.log("Failed to fetch Mindfulness activity data from DB: \(error)")
        }
    }

    func getActivityByName(_ name: String) -> PartialActivity? {
        return partialActivitiesAllLocales.first { $0.name == name }
    }
    
    static func mock() -> ProfileViewModel {
        return ProfileViewModel()
    }
}
