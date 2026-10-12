//
//  HealthkitViewModel.swift
//  MindApp
//
//  Created by Michael Slavev on 03.04.2024.
//

import Foundation
import HealthKit

enum PermissionsState: Hashable {
    case Granted
    case Revoked
}

/// Class holding and interacting with all the health data that might be required by some  views, e.g. by ``LatestDataView``
@MainActor
final class HealthkitViewModel: ObservableObject {
    @Injected private var healthKitManager: HealthKitManager
    @Injected private var healthDBManager: HealthDBManager
    
    @Published var permissionsState: PermissionsState = .Revoked
    @Published var latestSdnnHRV: Double?
    @Published var latestHR: Double?
    @Published var latestRHR: Double?
    
    @Published var averageHRV30: (averageRMSSD: Double?, averageSDNN: Double?)
    @Published var averageRHR30: Double?
    
    @Published var hrvDataPoints: [HRVDataPoint] = []
    @Published var mindfulnessDataPoints: [MindfulDataPoint] = []
    
    @Published var isLoading: Bool = false
    
    init() {
        requestPermissions()
    }
    
    func checkPermissions() {
        healthKitManager.checkAuthorizationStatus { hasAccess in
            self.permissionsState = hasAccess ? .Granted : .Revoked
        }
    }
    
    func requestPermissions() {
        healthKitManager.requestAuthorization()
        // healthKitManager.observeHeartbeatSeries()
    }
    
    func clearHRVDataPoints() {
        hrvDataPoints = []
    }
    
    func fetchLatestHealthData(date: Date) async {
        isLoading = true
        
        do {
            latestSdnnHRV = try await healthKitManager.fetchLatestHRV()
            latestHR = try await healthKitManager.fetchLatestHR()
            latestRHR = try await healthKitManager.fetchLatestRHR()
            averageHRV30 = try await healthKitManager.fetchAverageHRVLastXDays()
            averageRHR30 = try await healthKitManager.fetchAverageRHRLast30Days()
            
            await fetchHRVData(date: date)
            await fetchMindfullData(date: date)
            
        } catch {
            Logger.log("Failed to fetch health data: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchHRVData(date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        guard let averageHRV30 = averageHRV30.averageRMSSD
        else {
            Logger.log("No data yet.")
            return
        }
        
        do {
            let heartbeatSeriesSamples = try await healthKitManager.fetchHeartbeatSeriesSamples(from: startOfDay, to: endOfDay)
            var tempHrvDataPoints = [HRVDataPoint]()
            
            for sample in heartbeatSeriesSamples {
                do {
                    let rrIntervals = try await healthKitManager.fetchRRIntervals(from: sample)
                    let rmssd = try HealthUtils.calculateRMSSD(rrIntervals: rrIntervals)
                    let sdnn = try HealthUtils.calculateSDNN(rrIntervals: rrIntervals)
                    let stressLevel = HealthUtils.calculateStressLevel(averageHRV30: averageHRV30, hrv: rmssd)
                    
                    let hrvDataPoint = HRVDataPoint(date: sample.startDate, sdnnHrv: sdnn, rmssdHrv: rmssd, stressLevel: stressLevel)
                    tempHrvDataPoints.append(hrvDataPoint)
                } catch {
                    Logger.log("Failed to process sample: \(error)")
                }
            }
            
            hrvDataPoints = tempHrvDataPoints
        } catch {
            Logger.log("Failed to fetch beat-to-beat samples: \(error)")
        }
    }
    
    func fetchMindfullData(date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let mindfulSamples = try await healthKitManager.fetchMindfulnessMinutes(from: startOfDay, to: endOfDay)
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
                        let _ = metadata["SourceApp"] as? String,
                        let _ = metadata["AISummary"] as? String
                {
                    //Do nothing
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
        } catch {
            Logger.log("Failed to fetch mindfulness samples: \(error)")
        }
    }
    
    static func mock() -> HealthkitViewModel {
        return HealthkitViewModel()
    }
}
