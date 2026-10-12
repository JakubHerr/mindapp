//
//  SessionViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 16.05.2024.
//

import Foundation
import SwiftUI

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var activity: Activity

    @Published var timeSelection: TimeSelection

    @Published var selectedSound: Sound = .none
    @Published var volume: Double = 0.5
    @Published var isChimeOn: Bool = false
    @Published var isHapticsOn: Bool = false

    private var startTime: Date?
    private var endTime: Date?

    init(activity: Activity) {
        self.activity = activity
        self.timeSelection = TimeSelection(minutes: activity.meditation?.minutesDuration ?? 0, seconds: activity.meditation?.secondsDuration ?? 0)
    }

    func startSession() {
        startTime = Date()
    }

    func endSession() {
        endTime = Date()
    }

    func getStartTime() -> Date? {
        return startTime
    }

    func getEndTime() -> Date? {
        return endTime
    }

    func resolveTimerText() -> String {
        if timeSelection.minutes == 0 && timeSelection.seconds == 0 { return NSLocalizedString("mind_time_unlimited_short", comment: "Unlimited time") }

        let minutes = NSLocalizedString("minutes", comment: "Minutes")
        let minute = NSLocalizedString("minute", comment: "Minute")

        return "\(timeSelection.minutes) \(timeSelection.minutes > 1 ? minutes : minute)"
    }

    func resolveSoundText(sound: Sound? = nil) -> String {
        let soundToTranslate = sound ?? selectedSound

        switch soundToTranslate {
        case .none:
            return NSLocalizedString("mind_sound_none", comment: "No sound")
        case .bird:
            return NSLocalizedString("mind_sound_bird", comment: "Bird whistling sound")
        case .rainfall:
            return NSLocalizedString("mind_sound_rainfall", comment: "Rainfall sound")
        case .harmonic:
            return NSLocalizedString("mind_sound_harmonic", comment: "Harmonic sound")
        }
    }
    
    static func mock() -> SessionViewModel {
        return SessionViewModel(activity: Activity.mock())
    }
    
}
