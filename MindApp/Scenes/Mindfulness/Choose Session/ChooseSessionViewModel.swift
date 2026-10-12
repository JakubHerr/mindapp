//
//  ChooseSessionViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 20.05.2024.
//

import SwiftUI

/// Class holding all the necessary data for ``ChooseSessionView``
@MainActor
final class ChooseSessionViewModel: ObservableObject {
    @Injected private var mindfulnessDbManager: MindfulnessDBManager
    @Injected private var coreDataDBManager: CoreDataDBManager

    @Published var isLoading = false
    @Published var mindfulnessTypes: [Activity.MindfulnessType] = []

    func fetchMindfulnessTypes() async {
        isLoading = true
        defer { isLoading = false }

        do {
            mindfulnessTypes = try await mindfulnessDbManager.fetchMindfulnessTypes()
            coreDataDBManager.saveMindfulnessTypes(types: mindfulnessTypes)
        } catch {
            Logger.log("Failed to fetch Mindfulness types data from DB: \(error)")
            mindfulnessTypes = coreDataDBManager.fetchMindfulnessTypesSortedByName()
            Logger.log("Loaded Mindfulness types data from CoreData DB")
        }
    }
    
    static func mock() -> ChooseSessionViewModel {
        return ChooseSessionViewModel()
    }
}
