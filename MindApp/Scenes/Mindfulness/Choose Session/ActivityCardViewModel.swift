//
//  ActivityCardViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 16.05.2024.
//

import Foundation

/// Class holding and interacting with all the necessary data for the ``ActivityCardView``
@MainActor
final class ActivityCardViewModel: ObservableObject {
    @Published var activity: Activity

    init(activity: Activity) {
        self.activity = activity
    }
    
    /// Function to get the activity duration in `String` type
    /// - Parameter activity: The ``Activity`` for which to get the duration
    /// - Returns: `String` containing the duration of the ``activity`` in text form
    func getDurationText(for activity: Activity) -> String {
        switch activity.category {
        case .meditation:
            if let minutes = activity.meditation?.minutesDuration, let seconds = activity.meditation?.secondsDuration {
                if minutes == 1 {
                    return String(format: NSLocalizedString("%d minute %d seconds", comment: ""), minutes, seconds)
                }

                return String(format: NSLocalizedString("%d minutes %d seconds", comment: ""), minutes, seconds)
            } else if let minutes = activity.meditation?.minutesDuration {
                return String(format: NSLocalizedString("%d minutes", comment: ""), minutes)
            } else if let seconds = activity.meditation?.secondsDuration {
                return String(format: NSLocalizedString("%d seconds", comment: ""), seconds)
            } else {
                return NSLocalizedString("mind_time_unlimited", comment: "")
            }

        case .breathing:
            if let breathing = activity.breathing {
                let totalDuration = (breathing.inhaleDuration + breathing.exhaleDuration + (breathing.holdDuration ?? 0) + (breathing.secondHoldDuration ?? 0)) * breathing.cycleCount
                let minutes = totalDuration / 60
                let seconds = totalDuration % 60

                if minutes == 0 {
                    return String(format: NSLocalizedString("%d seconds", comment: ""), seconds)
                }

                if minutes == 1 {
                    if seconds <= 5 {
                        return String(format: NSLocalizedString("%d minute", comment: ""), minutes)
                    }
                    return String(format: NSLocalizedString("%d minute %d seconds", comment: ""), minutes, seconds)
                }

                return String(format: NSLocalizedString("%d minutes %d seconds", comment: ""), minutes, seconds)
            } else {
                return NSLocalizedString("mind_time_unlimited", comment: "")
            }
        }
    }
    
    static func mock() -> ActivityCardViewModel {
        return ActivityCardViewModel(activity: Activity.mock())
    }
}
