//
//  CategoryCardViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 28.04.2024.
//

import Foundation
import CoreData

/// Class holding and interacting with all the necessary data for the ``CategoriesView``
@MainActor
final class CategoriesViewModel: ObservableObject {
    @Injected private var mindfulnessDbManager: MindfulnessDBManager
    @Injected private var coreDataDBManager: CoreDataDBManager
    
    @Published var isLoading = false
    @Published var activities: [Activity] = []
    @Published var selectedType: String = "all"
    
    /// Calls the mindfulness database and tries to fetch all activities
    func fetchActivities() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            activities = try await mindfulnessDbManager.fetchActivities()
            coreDataDBManager.saveActivities(activities: activities)
            Logger.log("Activities succesfully fetched")
        } catch {
            Logger.log("Failed to fetch Mindfulness activity data from DB: \(error)")
            activities = coreDataDBManager.fetchActivitiesSortedByName()
        }
    }
    
    /// Function to filter the activities based on their category and type
    /// - Parameters:
    ///   - category: ``MindfulnessCategory`` that the returning activities need to conform to
    ///   - type: `String?` containing the type of ``Activity`` they need to be
    /// - Returns: Array of ``Activity`` fitting the inputed filters
    func getFilteredActivities(category: MindfulnessCategory, type: String?) -> [Activity] {
        return activities.filter { activity in
            activity.category == category && (type == nil || type == "all" || activity.types.contains { $0.name == type })
        }
    }

    func selectType(_ type: String) {
        selectedType = type
    }
    
    static func mock() -> CategoriesViewModel {
        return CategoriesViewModel()
    }
}
