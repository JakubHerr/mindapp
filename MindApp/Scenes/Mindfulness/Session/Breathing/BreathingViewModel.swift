//
//  BreathingViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 16.05.2024.
//

import SwiftUI

@MainActor
final class BreathingViewModel: ObservableObject {
    @Injected private var healthKitManager: HealthKitManager

    @Published var isActive: Bool = false
    @Published var currentCycleCount: Int = 0

    @Published var inhaleDuration: TimeInterval
    @Published var exhaleDuration: TimeInterval
    @Published var holdDuration: TimeInterval
    @Published var secondHoldDuration: TimeInterval
    @Published var cycleCount: Int

    private var activity: Activity

    init(activity: Activity) {
        self.activity = activity
        self.inhaleDuration = TimeInterval(activity.breathing?.inhaleDuration ?? 0)
        self.exhaleDuration = TimeInterval(activity.breathing?.exhaleDuration ?? 0)
        self.holdDuration = TimeInterval(activity.breathing?.holdDuration ?? 0)
        self.secondHoldDuration = TimeInterval(activity.breathing?.secondHoldDuration ?? 0)
        self.cycleCount = activity.breathing?.cycleCount ?? 1
    }
    
    static func mock() -> BreathingViewModel {
        return BreathingViewModel(activity: .mock())
    }
}
