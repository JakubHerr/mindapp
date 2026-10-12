//
//  AppDelegate.swift
//  MindApp
//
//  Created by Michael Slavev on 01.04.2024.
//

import BackgroundTasks
import HealthKit
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let taskId = "vse.cz.MindApp"
    private let healthKitManager = HealthKitManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.log("Delegate started.", .info)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        healthKitManager.observeHeartbeatSeries()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Logger.log("Could not schedule app refresh: \(error)", .error)
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = BlockOperation {
            Task {
                await self.healthKitManager.observeHeartbeatSeries() //added await
            }
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }

        queue.addOperation(operation)
    }
}
