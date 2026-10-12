//
//  SessionEvaluationViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 19.05.2024.
//

import Foundation

/// Class holding and interacting with all the necessary data for ``SessionEvaluationView``
@MainActor
final class SessionEvaluationViewModel: ObservableObject {
    @Injected private var healthKitManager: HealthKitManager

    @Published var selectedFeeling: Feeling = .same

    func addMindfulMinutes(feeling: Feeling, activity: Activity, startTime: Date?, endTime: Date?) async {
        do {
            guard let startTime = startTime else { return }
            guard let endTime = endTime else { return }

            _ = try await healthKitManager.addMindfulnessMinutes(startDate: startTime, endDate: endTime, category: activity.category.rawValue, type: activity.name, feeling: feeling.dbName)
        } catch {
            Logger.log("Failed to add mindful minutes: ", .error)
        }
    }
}
