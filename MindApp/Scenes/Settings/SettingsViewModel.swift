//
//  SettingsViewModel.swift
//  MindApp
//
//  Created by Michael Slavev on 14.05.2024.
//

import Foundation
import HealthKit
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Injected private var healthKitManager: HealthKitManager

    @Published var permissionsState: PermissionsState = .Revoked

    @Published var showingAboutHrvInfoSheet: Bool = false
    @Published var showingStressMeasurementInfoSheet: Bool = false
    @Published var showingHowOftenInfoSheet: Bool = false
    @Published var showingTimePicker = false

    @Published var notificationMindfulReminderEnabled: Bool
    @Published var notificationStressEnabled: Bool

    private var mindStartTime: Date?
    private var mindEndTime: Date?

    let notificationTitleLabel = NSLocalizedString("scheduled_notification_title", comment: "Title label")
    let notificationBodyLabel = NSLocalizedString("scheduled_notification_body", comment: "Body label")

    init() {
        notificationMindfulReminderEnabled = UserDefaults.standard.bool(forKey: UserDefaultConstants.mindfulnessNotificationEnabled)
        notificationStressEnabled = UserDefaults.standard.bool(forKey: UserDefaultConstants.stressNotificationEnabled)
        requestPermissions()
        requestNotificationPermissions()
    }

    // MARK: Sheet toggles

    func toggleAboutHrvInfoSheet() {
        showingAboutHrvInfoSheet.toggle()
    }

    func toggleStressMeasurementInfoSheet() {
        showingStressMeasurementInfoSheet.toggle()
    }

    func toggleHowOftenInfoSheet() {
        showingHowOftenInfoSheet.toggle()
    }

    // MARK: Functions

    func checkPermissions() {
        healthKitManager.checkAuthorizationStatus { hasAccess in
            self.permissionsState = hasAccess ? .Granted : .Revoked
        }
    }

    func requestPermissions() {
        healthKitManager.requestAuthorization()
    }

    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }

        UIApplication.shared.open(settingsUrl)
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                Logger.log("Error requesting notification permissions: \(error)", .error)
            }
        }
    }

    func toggleStressNotifications() async {
        try? await Task.sleep(nanoseconds: 250_000_000)

        if !notificationStressEnabled {
            UserDefaults.standard.set(false, forKey: UserDefaultConstants.stressNotificationEnabled)
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaultConstants.stressNotificationEnabled)
        }
    }

    // MARK: Scheduled mind notification

    func scheduleNotification(time: Date) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitleLabel
        content.body = notificationBodyLabel
        content.sound = UNNotificationSound.default

        // Set up a daily trigger at the selected time
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.log("Error scheduling notification: \(error)", .error)
            } else {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(identifier, forKey: UserDefaultConstants.mindfulnessNotificationIdentifier)
                    UserDefaults.standard.set(true, forKey: UserDefaultConstants.mindfulnessNotificationEnabled)
                    self.notificationMindfulReminderEnabled = true
                    Logger.log("Notification scheduled successfully with identifier: \(identifier) for time: \(dateComponents)", .success)
                }
            }
        }
    }

    func unscheduleNotification() {
        if let identifier = UserDefaults.standard.string(forKey: UserDefaultConstants.mindfulnessNotificationIdentifier) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            DispatchQueue.main.async {
                Logger.log("Notification with identifier \(identifier) unscheduled successfully", .success)
                UserDefaults.standard.removeObject(forKey: UserDefaultConstants.mindfulnessNotificationIdentifier)
                UserDefaults.standard.set(false, forKey: UserDefaultConstants.mindfulnessNotificationEnabled)
                self.notificationMindfulReminderEnabled = false
            }
        } else {
            Logger.log("No notification to unschedule", .info)
        }
    }
    
    static func mock() -> SettingsViewModel {
        return SettingsViewModel()
    }
}
