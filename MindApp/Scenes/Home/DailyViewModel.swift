//
//  DailyViewModel.swift
//  MindApp
//
//  Created by Michael Slavev on 02.05.2024.
//

import Foundation

/// Class holding and interacting with all the data required by ``DailyView`` in order to function properly
@MainActor
final class DailyViewModel: ObservableObject {
    @Injected private var healthKitManager: HealthKitManager
    @Injected private var mindfulnessDbManager: MindfulnessDBManager
    @Injected private var coreDataDBManager: CoreDataDBManager
    
    @Published var showingInfoSheet: Bool = false
    @Published var recommendedActivity: Activity?
    
    private var topMindfulnessActivities: [Activity] = []
    private var activities: [Activity] = []
    private var mindfulnessDataPoints: [MindfulDataPoint] = []
    private var resolvedDate: Date?
    
    func toggleInfoSheet() {
        showingInfoSheet.toggle()
    }
    
    /// Tries to fetch the available activities
    /// > Activities might be needed in order to recommend an activity to the user in ``resolveActivityForToday()``
    func fetchActivities() async {
        do {
            activities = try await mindfulnessDbManager.fetchActivities()
//            coreDataDBManager.deleteAll()
            coreDataDBManager.saveActivities(activities: activities)
        } catch {
            Logger.log("Failed to fetch Mindfulness activity data from DB: \(error)")
            activities = coreDataDBManager.fetchActivitiesSortedByName()
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
    
    private func getActivityByName(_ name: String) -> Activity? {
        return activities.first { $0.name == name }
    }
    
    private func resolveRecommendedActivities() async {
        var typeScores = [String: Int]()
        
        do {
            await fetchActivities()
            try await fetchMindfulnessDataPoints()
        } catch {
            Logger.log("Mindfulness data fetch failed.")
        }
        
        for dataPoint in mindfulnessDataPoints {
            typeScores[dataPoint.type, default: 0] += dataPoint.feelingScore
        }
        
        let sortedTypeScores = typeScores.sorted { $0.value > $1.value }
        let positiveTypeScores = sortedTypeScores.filter { $0.value >= 0 }
        let mappedTypes = positiveTypeScores.map { $0.key }
        
        var mappedActivities = [Activity]()
        for type in mappedTypes {
            if let activity = getActivityByName(type) {
                mappedActivities.append(activity)
            }
        }
        
        if mappedActivities.count < 3 {
            let shuffledActivities = activities.shuffled()
            
            for activity in shuffledActivities {
                if mappedActivities.count >= 3 {
                    break
                }
                
                if !mappedActivities.contains(where: { $0.id == activity.id }) {
                    mappedActivities.append(activity)
                }
            }
        }
        
        var topActivities = Array(mappedActivities.shuffled().prefix(3))
        
        if let randomPositiveActivity = activities.randomElement(), !topActivities.contains(where: { $0.id == randomPositiveActivity.id }) && positiveTypeScores.contains(where: { $0.key == randomPositiveActivity.name }) {
            topActivities.append(randomPositiveActivity)
        }
                
        topMindfulnessActivities = topActivities
    }
    
    func resolveActivityForToday() async {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastResolved = resolvedDate, Calendar.current.isDate(lastResolved, inSameDayAs: today) { return }
        
        await resolveRecommendedActivities()
        
        resolvedDate = today
        recommendedActivity = topMindfulnessActivities.randomElement()
    }
    
    static func mock() -> DailyViewModel {
        return DailyViewModel()
    }
}
