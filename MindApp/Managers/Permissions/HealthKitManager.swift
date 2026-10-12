//
//  HealthKitManager.swift
//  MindApp
//
//  Created by Michael Slavev on 01.04.2024.
//

import Foundation
import HealthKit
import UserNotifications

/// Manager class that handles notifying / requiring and specifying all the records the app needs to read from the Apple Health app
class HealthKitManager {
    private let healthStore = HKHealthStore()
    private var isObservingHeartbeatSeries = false

    // MARK: Defining needed read and write types

    // Defining which types we need to read from HK
    private let readTypes: Set<HKObjectType> = [
         HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
         HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries)!,
        HKSeriesType.heartbeat(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
         HKObjectType.quantityType(forIdentifier: .stepCount)!,
         HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, //cals?
    ]

    // Defining which types we need to write into HK
    private let writeTypes: Set<HKSampleType> = [
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
    ]

    // MARK: basic HK functions

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            Logger.log("Health data not available", .info)
            return
        }

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, _ in
            if !success {
                Logger.log("Failed to request authorization on HK types: ", .error, .error)
            }
        }
    }

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        var hasAccessToAllTypes = true

        for type in readTypes.union(writeTypes) {
            dispatchGroup.enter()
            healthStore.getRequestStatusForAuthorization(toShare: writeTypes, read: Set([type])) { status, error in
                if status != .unnecessary || error != nil {
                    hasAccessToAllTypes = false
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(hasAccessToAllTypes)
        }
    }

    // MARK: Universal query

    private func queryLatestSampleOfType(sampleType: HKSampleType, unit: HKUnit) async throws -> Double? {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let sample = samples?.first as? HKQuantitySample {
                        let value = sample.quantity.doubleValue(for: unit)
                        continuation.resume(returning: value)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    //MARK: General queries
    
    func fetchSex() async throws -> HKBiologicalSexObject? {
        return try healthStore.biologicalSex()
    }
    
    func fetchAge() async throws -> Int? {
        let calendar = Calendar.current
        let birthDateComponents = try healthStore.dateOfBirthComponents()
        
        guard let birthDate = calendar.date(from: birthDateComponents) else {
            return nil
        }
        
        let now = Date()
        // Calculate the age in years
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year
    }

    // MARK: Latest queries

    func fetchLatestHRV() async throws -> Double? {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let heartbeatSeriesSamples = try await fetchHeartbeatSeriesSamples(from: startOfDay, to: now)

        guard let latestSample = heartbeatSeriesSamples.last else {
            Logger.log("No heartbeat series samples available for today.")
            return nil
        }

        let rrIntervals = try await fetchRRIntervals(from: latestSample)
        guard let rmssd = try? HealthUtils.calculateRMSSD(rrIntervals: rrIntervals) else {
            Logger.log("Failed to calculate RMSSD from RR intervals.")
            return nil
        }

        return rmssd
    }

    func fetchLatestHR() async throws -> Double? {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample type not available"])
        }

        return try await queryLatestSampleOfType(sampleType: sampleType, unit: HKUnit(from: "count/min"))
    }

    func fetchLatestRHR() async throws -> Double? {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample type not available"])
        }

        return try await queryLatestSampleOfType(sampleType: sampleType, unit: HKUnit(from: "count/min"))
    }

    // MARK: Queries

    func fetchAverageRHRLast30Days(lastDay: Date = Date()) async throws -> Double? {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample type not available"])
        }

        let endDate = lastDay
        let startDate = endDate.adding(days: -30)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, statistics, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let averageQuantity = statistics?.averageQuantity() {
                        let averageValue = averageQuantity.doubleValue(for: HKUnit(from: "count/min"))
                        continuation.resume(returning: averageValue)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchHeartRateSamples(from startDate: Date, to endDate: Date) async throws -> [HKQuantitySample] {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample type not available"])
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let samples = samples as? [HKQuantitySample] {
                        continuation.resume(returning: samples)
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    // MARK: Mindfull minutes

    func addMindfulnessMinutes(startDate: Date, endDate: Date, category: String, type: String, feeling: String) async throws -> Bool? {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindfulness type not available"])
        }

        let additionalInfo = [
            "SourceApp": "MindApp",
            "Category": category,
            "Type": type,
            "Feeling": feeling,
        ]

        let mindfulSample = HKCategorySample(type: mindfulType, value: 0, start: startDate, end: endDate, metadata: additionalInfo)

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(mindfulSample) { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        }
    }
    
    func addAIHealthSummary(date: Date = .now, summary: String) async throws -> Bool? {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindfulness type not available"])
        }

        let additionalInfo = [
            "SourceApp": "MindApp",
            "Type": "AIHealthSummary",
            "Summary": summary
        ]

        let mindfulSample = HKCategorySample(type: mindfulType, value: 0, start: date, end: date, metadata: additionalInfo)

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(mindfulSample) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func fetchLatestAISummary() async throws -> HKCategorySample? {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindful session type not available"])
        }
        
        let predicate = NSPredicate(format: "metadata.%K == %@", "Type", "AIHealthSummary")
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let latestSample = samples?.first as? HKCategorySample {
                        continuation.resume(returning: latestSample)
                    } else {
                        continuation.resume(returning: nil) // No matching entry found
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    
    func addReflectionResult(startDate: Date, endDate: Date, details: [FHIRItemBase]) async throws -> Bool? {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindfulness type not available"])
        }

        var additionalInfo = [
            "SourceApp": "MindApp",
            "Type": "Reflection",
        ]
        
        for item in details {
            if let intVal = item as? FHIRIntegerItem {
                additionalInfo.updateValue(String(intVal.selected ?? 5) + "/10", forKey: intVal.variableName ?? "unknown")
            }
            else if let boolVal = item as? FHIRBooleanItem {
                additionalInfo.updateValue(String(boolVal.selected ?? false), forKey: boolVal.variableName ?? "unknown")
            }
            else if let choiceVal = item as? FHIRChoiceItem {
                var tmpString = ""
                for option in choiceVal.selected {
                    if !tmpString.isEmpty {
                        tmpString.append(", ")
                    }
                    tmpString.append(option.valueString)
                }
                additionalInfo.updateValue(tmpString, forKey: choiceVal.variableName ?? "unknown")
            }
            else if let textVal = item as? FHIRTextItem {
                additionalInfo.updateValue(textVal.value, forKey: textVal.variableName ?? "unknown")
            }
        }

        let mindfulSample = HKCategorySample(type: mindfulType, value: 0, start: startDate, end: endDate, metadata: additionalInfo)

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(mindfulSample) { success, error in
                DispatchQueue.main.sync {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        }
    }
    
    func fetchLatestReflection() async throws -> HKCategorySample? {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindful session type not available"])
        }
        
        let predicate = NSPredicate(format: "metadata.%K == %@", "Type", "Reflection")
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.sync {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let latestSample = samples?.first as? HKCategorySample {
                        continuation.resume(returning: latestSample)
                    } else {
                        continuation.resume(returning: nil) // No matching entry found
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchLatestReflections(number: Int = 3) async throws -> [HKCategorySample] {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindful session type not available"])
        }
        
        let predicate = NSPredicate(format: "metadata.%K == %@", "Type", "Reflection")
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: number, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.sync {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let latestSamples = samples as? [HKCategorySample] {
                        continuation.resume(returning: latestSamples)
                    } else {
                        continuation.resume(returning: []) // No matching entry found
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchReflectionsInRange(from startIndex: Int, to endIndex: Int) async throws -> [HKCategorySample] {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindful session type not available"])
        }

        let predicate = NSPredicate(format: "metadata.%K == %@", "Type", "Reflection")
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let fetchLimit = endIndex // we need to fetch at least up to the endIndex to slice

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: fetchLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let allSamples = samples?.compactMap({ $0 as? HKCategorySample }) {
                        let safeStart = max(0, min(startIndex, allSamples.count))
                        let safeEnd = max(0, min(endIndex, allSamples.count))
                        let rangeSamples = Array(allSamples[safeStart..<safeEnd])
                        continuation.resume(returning: rangeSamples)
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }

            healthStore.execute(query)
        }
    }

    func fetchMindfulnessMinutes(from startDate: Date, to endDate: Date) async throws -> [HKCategorySample] {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mindful session type not available"])
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let samples = samples as? [HKCategorySample] {
                        let filteredSamples = samples.filter { sample in
                            guard let metadata = sample.metadata else { return false }
                            return metadata["SourceApp"] as? String == "MindApp"
                        }
                        continuation.resume(returning: filteredSamples)
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    // MARK: Beat-to-beat queries and calculations

    func fetchHeartbeatSeriesSamples(from startDate: Date, to endDate: Date) async throws -> [HKHeartbeatSeriesSample] {
        guard let sampleType = HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample type not available"])
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let samples = samples as? [HKHeartbeatSeriesSample] {
                        continuation.resume(returning: samples)
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchRRIntervals(from heartbeatSeriesSample: HKHeartbeatSeriesSample) async throws -> [Double] {
        return try await withCheckedThrowingContinuation { continuation in
            var lastTime: Double?
            var intervals: [Double] = []

            let query = HKHeartbeatSeriesQuery(heartbeatSeries: heartbeatSeriesSample) { _, timeSinceSeriesStart, precededByGap, done, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if let lastTimeUnwrapped = lastTime, !precededByGap {
                    let interval = timeSinceSeriesStart - lastTimeUnwrapped
                    intervals.append(interval)
                }

                lastTime = timeSinceSeriesStart

                if done {
                    continuation.resume(returning: intervals)
                }
            }

            healthStore.execute(query)
        }
    }

    func fetchAverageHRVLastXDays(lastDay: Date = Date(), totalDaysAverage: Int = 30) async throws -> (averageRMSSD: Double?, averageSDNN: Double?) {
        let endDate = lastDay
        let startDate = endDate.adding(days: -totalDaysAverage)

        let heartbeatSeriesSamples = try await fetchHeartbeatSeriesSamples(from: startDate, to: endDate)

        var rmssdValues: [Double] = []
        var sdnnValues: [Double] = []

        for sample in heartbeatSeriesSamples {
            do {
                let rrIntervals = try await fetchRRIntervals(from: sample)
                if let rmssd = try? HealthUtils.calculateRMSSD(rrIntervals: rrIntervals) {
                    rmssdValues.append(rmssd)
                }
                if let sdnn = try? HealthUtils.calculateSDNN(rrIntervals: rrIntervals) {
                    sdnnValues.append(sdnn)
                }

            } catch {
                Logger.log("Failed to process sample: \(error)")
            }
        }

        let averageRMSSD = rmssdValues.isEmpty ? nil : rmssdValues.reduce(0.0, +) / Double(rmssdValues.count)
        let averageSDNN = sdnnValues.isEmpty ? nil : sdnnValues.reduce(0.0, +) / Double(sdnnValues.count)

        return (averageRMSSD, averageSDNN)
    }
    
    func fetchAverageStepsLastXDays(lastDay: Date = Date(), totalDaysAverage: Int = 30) async throws -> Double? {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"])
        }
        
        let endDate = lastDay
        let startDate = Calendar.current.date(byAdding: .day, value: -totalDaysAverage, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let sumQuantity = statistics?.sumQuantity() {
                        let totalSteps = sumQuantity.doubleValue(for: HKUnit.count())
                        let averageSteps = totalSteps / Double(totalDaysAverage)
                        continuation.resume(returning: averageSteps)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchSteps(for date: Date) async throws -> Double? {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"])
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let sumQuantity = statistics?.sumQuantity() {
                        let totalSteps = sumQuantity.doubleValue(for: HKUnit.count())
                        continuation.resume(returning: totalSteps)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    func fetchAverageCaloriesLastXDays(lastDay: Date = Date(), totalDaysAverage: Int = 30) async throws -> Double? {
        guard let energyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Active energy burned type not available"])
        }
        
        let endDate = lastDay
        let startDate = Calendar.current.date(byAdding: .day, value: -totalDaysAverage, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: energyBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let sumQuantity = statistics?.sumQuantity() {
                        let totalCalories = sumQuantity.doubleValue(for: HKUnit.kilocalorie())
                        let averageCalories = totalCalories / Double(totalDaysAverage)
                        continuation.resume(returning: averageCalories)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    // MARK: Observers

    func observeHeartbeatSeries() {
        guard !isObservingHeartbeatSeries else { return }
        isObservingHeartbeatSeries = true

        guard let sampleType = HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries) else {
            Logger.log("Heartbeat Series type is not available.", .info)
            return
        }

        healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { _, error in
            if error != nil {
                Logger.log("Failed to enable background delivery", .error)
            } else {
                Logger.log("Background delivery enabled.", .success)
            }
        }

        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, _ in

            Task {
                await self.handleNewHeartbeatSeriesSamples {
                    completionHandler()
                }
            }
        }
        healthStore.execute(query)
    }

    func handleNewHeartbeatSeriesSamples(completionHandler: @escaping () -> Void) async {
        let notificationStressEnabled = UserDefaults.standard.bool(forKey: UserDefaultConstants.stressNotificationEnabled)
        if !notificationStressEnabled {
            completionHandler()
            return
        }

        do {
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)

            let averageHRV30 = try await fetchAverageHRVLastXDays()
            let heartbeatSeriesSamples = try await fetchHeartbeatSeriesSamples(from: startOfDay, to: now)

            guard let latestSample = heartbeatSeriesSamples.last else {
                Logger.log("No new heartbeat series samples available.", .info)
                return
            }

            let rrIntervals = try await fetchRRIntervals(from: latestSample)
            if let rmssd = try? HealthUtils.calculateRMSSD(rrIntervals: rrIntervals) {
                Logger.log("Calculated RMSSD: \(rmssd)", .success)

                let stressLevel = HealthUtils.calculateStressLevel(averageHRV30: averageHRV30.averageRMSSD!, hrv: rmssd)

                if stressLevel == .Stressed {
                    sendNotification()
                } else {
                    Logger.log("Not stressed", .info)
                }

                completionHandler()
            } else {
                Logger.log("Failed to calculate RMSSD.", .error)
            }
        } catch {
            Logger.log("Error handling new heartbeat series samples: \(error)", .error)
        }
    }

    private func sendNotification() {
        let notificationTitleLabel = NSLocalizedString("stress_notification_title", comment: "Stress notification - Title label")
        let notificationBodyLabel = NSLocalizedString("stress_notification_body", comment: "Stress notification - Body label")

        let content = UNMutableNotificationContent()

        content.title = notificationTitleLabel
        content.body = notificationBodyLabel

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.log("Failed to send notification: \(error.localizedDescription)", .error)
            } else {
                Logger.log("Stress notification sent successfully", .success)
            }
        }
    }
    
    //MARK: Getters for ease of use
    func fetchHeartData() async -> String? {
        var retVal: [String] = []
        do {
            if let lhr = try await fetchLatestHR() {
                retVal.append("Latest HR: \(lhr)")
            }
        }
        catch {
            Logger.log("Latest HR fetch failed: \(error)", .error)
        }
        
        do {
            if let lhrv = try await fetchLatestHRV() {
                retVal.append("Latest HRV: \(lhrv)")
            }
        }
        catch {
            Logger.log("Latest HRV fetch failed: \(error)", .error)
        }
        
        do {
            if let lrhr = try await fetchLatestRHR() {
                retVal.append("Latest RHR: \(lrhr)")
            }
        }
        catch {
            Logger.log("Latest RHR fetch failed: \(error)", .error)
        }
        
        do {
            if let aRHR30 = try await fetchAverageRHRLast30Days() {
                retVal.append("Average RHR in last 30 days: \(aRHR30)")
            }
        }
        catch {
            Logger.log("Average RHR in last 30 days fetch failed: \(error)", .error)
        }
        
        do {
            let aHRV30 = try await fetchAverageHRVLastXDays()
            
            if let aRMSSD30 = aHRV30.averageRMSSD {
                retVal.append("Average RMSSD in last 30 days: \(aRMSSD30)")
            }
            
            if let aSDNN30 = aHRV30.averageSDNN {
                retVal.append("Average SDNN in last 30 days: \(aSDNN30)")
            }
        }
        catch {
            Logger.log("Average HRV in last 30 days fetch failed: \(error)", .error)
        }
        if !retVal.isEmpty {
            return retVal.joined(separator: "\n")
        }
        return nil
    }
    
    func fetchLast7DaysSteps() async -> String? {
        var results: [String] = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M."

        for i in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            do {
                if let steps = try await fetchSteps(for: date) {
                    var formattedDate: String = ""
                    if i == 1 {
                        formattedDate = "Yesterday"
                    }
                    else if i == 0 {
                        formattedDate = "Today"
                    }
                    else {
                        formattedDate = dateFormatter.string(from: date)                        
                    }
                    let formattedSteps = Int(steps)
                    results.append("\(formattedDate) - \(formattedSteps)")
                } else {
                    let formattedDate = dateFormatter.string(from: date)
                    results.append("\(formattedDate) - no data")
                }
            } catch {
                Logger.log("Failed to fetch steps for \(date): \(error)", .error)
            }
        }

        return results.isEmpty ? nil : results.joined(separator: "\n")
    }
    
}

// MARK: Extensions

extension Date {
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
