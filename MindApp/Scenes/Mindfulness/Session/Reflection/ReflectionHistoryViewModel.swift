//
//  ReflectionHistoryViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 30.03.2025.
//

import Foundation

class ReflectionHistoryViewModel: ObservableObject {
    @Published var sessions: [ReflectionEntry] = []
    @Published var isLoading: Bool = false
    @Published var hasMoreData = true
    
    private let pageSize = 10
    
    @Injected var hkm: HealthKitManager
        
    func loadMoreReflections() {
//        Logger.log("Loading more reflections")
        guard !isLoading, hasMoreData else { return }
        isLoading = true
        
        let startIndex = sessions.count
        let endIndex = startIndex + pageSize
        
        Task { @MainActor in
            do {
                let reflections = try await hkm.fetchReflectionsInRange(from: startIndex, to: endIndex)
                if reflections.isEmpty {
                    self.hasMoreData = false
                    //                        Logger.log("No more data available")
                }
                else {
                    for reflection in reflections {
                        let metadata: [(String, String)] = reflection.metadata?.map { key, value in
                            (key, "\(value)") // Convert all values to String for display
                        } ?? []
                        self.sessions.append(ReflectionEntry(date: reflection.startDate, contents: metadata))
                    }
                }
                self.isLoading = false
//                DispatchQueue.main.async {
//                }
            }
            catch {
                Logger.log("Error when fetching history reflections: \(error)", .error)
            }
        }
    }
    
    static var mock: ReflectionHistoryViewModel {
        let vm: ReflectionHistoryViewModel = .init()
        vm.sessions = [ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock, ReflectionEntry.mock]
        return vm
    }
}
