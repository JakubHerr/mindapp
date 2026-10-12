//
//  AISummaryViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 21.11.2024.
//

import Foundation
import Combine
import SwiftUI

enum VoteResult {
    case upvote
    case downvote
}

@MainActor
class AISummaryViewModel: ObservableObject {
    
    @Injected var dm: DifyManager
    
    @Injected var hm: HealthKitManager
    
    @Injected var am: AuthManager
        
    @Published var date: Date?
    
    @Published var timeRemaining: String = ""

    @Published var generating: Bool = false
    @Published var responseText: String = ""
    @Published var thinking: Bool = false
    
    var messageId: String = ""
    
    @Published var voted: Bool = false
    @Published var voteResult: VoteResult?
    
    private var cancellables = Set<AnyCancellable>()
    private var apiResponseBuffer: [String] = []
    
    var uid: String?
    var hd: String?
    var hdUp: Bool?
    var steps: String?
    var stepsUp: Bool?
    var age: String?
    var calories: String?
    var calsUp: Bool?
    
    @Published var error: DifyError?
    
    let summaryType: DifyAppType
    
    init(summaryType: DifyAppType) {
        self.summaryType = summaryType
        $generating
                .receive(on: RunLoop.main)
                .sink { [weak self] isGenerating in
                    if isGenerating {
                        self?.startBufferTimer()
                    } else {
                        self?.stopBufferTimer()
                        self?.appendBufferedText() // Final flush!
                    }
                }
                .store(in: &cancellables)
        
    }
    
    private func fetchUserData() async {
        do {
            self.uid = try await am.fetchUserInfo()
        }
        catch {
            Logger.log("Fetching user data failed: \(error)", .error)
        }
    }
    
    private var timerCancellable: AnyCancellable?

    private func startBufferTimer() {
        timerCancellable = Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.appendBufferedText()
            }
    }
    
    private func stopBufferTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func fetchHealthData() async {
        self.hd = await hm.fetchHeartData()
    }
    
    func initialFetch() async {
        if !self.generating {
            await fetchHealthSummary()
            updateCountdown()
        }
    }
    
    func fetchHealthSummary() async {
        do {
            if let lastSummary = try await hm.fetchLatestAISummary() {
                self.date = lastSummary.startDate
                let diff = abs(lastSummary.startDate.timeIntervalSinceNow)
//                if diff > 12 * 60 * 60 {
//                if diff > 60 {
                if diff > 10 {
                    await handleDifyHealthSummary()
                }
                else {
                    let latestSummary = try await hm.fetchLatestAISummary()
                    if let summary = latestSummary {
                        let metadata = summary.metadata ?? [:]
                        responseText = metadata["Summary"] as? String ?? "No summary available"
                    }
                }
            }
            else {
                self.date = .now
                await handleDifyHealthSummary()
            }
        }
        catch {
            Logger.log("Fetch of last summary failed: \(error)", .error)
        }
    }
    
    func formatDate(past date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, HH:mm" // Day, Month (short), Hour:Minute
        return formatter.string(from: date)
    }
    
    func formatDate(future date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Day, Month (short), Hour:Minute
        return formatter.string(from: date)
    }
    
    func updateCountdown() {
//        Logger.log("UPDATE COUNTDOWN")
        guard let lastDate = date else {
            Logger.log("No starting date found", .error)
            return
        }
        
//        let endDate = Calendar.current.date(byAdding: .hour, value: 12, to: lastDate)!
//        let endDate = Calendar.current.date(byAdding: .minute, value: 1, to: lastDate)!
        let endDate = Calendar.current.date(byAdding: .second, value: 10, to: lastDate)!
        let now = Date()
        
        let timeInterval = endDate.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            timeRemaining = "Ready!"
        } else {
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    private func sendRequest() async {
        
        self.generating.toggle()
        
        var tmpRequest: URLRequest?
        
        switch self.summaryType {
        case .healthMotivator, .healthSummary, .healthSupporter:
            tmpRequest = dm.createHealthSummaryRequest(type: self.summaryType, uid: self.uid, heartData: self.hd, calories: self.calories, steps: self.steps, age: self.age)
        default:
            Logger.log("Unsupported appType present", .error)
            return
        }
        
        guard let request = tmpRequest else {
            Logger.log("Creating request failed", .error)
            return
        }

        dm.handleSession(request: request,
                         onPartialResponse: { partial in
            if let msg = partial as? DifyMessageEventResponse {
                self.apiResponseBuffer.append(msg.answer)
                if self.messageId.isEmpty {
                    self.messageId = msg.id
//                    Logger.log(self.messageId)
                }
            }
        }, onCompletion: { complete in
//            if let msg = complete as? DifyChatCompletionResponse {
//                self.apiResponseBuffer.append(msg.answer)
//                if self.messageId.isEmpty {
//                    self.messageId = msg.messageId
////                    Logger.log(self.messageId)
//                }
//            }
            self.date = .now
            Task {
                try await self.hm.addAIHealthSummary(summary: self.responseText)
            }
            self.updateCountdown()
            self.generating.toggle()
        }, onError: { error in
            Logger.log("\(error)")
        })
    }
    
    func fetchRequiredHealthData() async {
        
        self.hd = await hm.fetchHeartData()
        
        do {
            if let lrhr = try await hm.fetchLatestRHR() {
                if let alrhr = try await hm.fetchAverageRHRLast30Days() {
                    self.hdUp = lrhr > alrhr
                }
            }
        }
        catch {
            Logger.log("No RHR data found", .error)
        }
        
//        self.hdUp = hm.fetchLatestRHR() > hm.fetchAverageRHRLast30Days()
        
        do {
            let lcals = try await hm.fetchAverageCaloriesLastXDays(totalDaysAverage: 1) ?? 0
            self.calories = String(lcals)
            self.calsUp = try await hm.fetchAverageCaloriesLastXDays() ?? 0 < lcals
        }
        catch {
            Logger.log("No calories data found", .error)
        }
        
        self.steps = String(await hm.fetchLast7DaysSteps() ?? "No data")
        
        do {
            self.stepsUp = try await hm.fetchSteps(for: .now) ?? 0 > hm.fetchAverageStepsLastXDays() ?? 0
        }
        catch {
            Logger.log("No steps data found", .error)
        }
        
        do {
            self.age = String(try await hm.fetchAge() ?? 0)
        }
        catch {
            Logger.log("No age data found", .error)
        }
    }
    
    func handleDifyHealthSummary() async {
        do {
            if self.uid == nil {
                self.uid = try await am.fetchUserInfo()
            }

            await fetchRequiredHealthData()
            
            await sendRequest()
        }
        catch {
            Logger.log("Error handling Dify health summary: \(error)", .error)
            self.error = DifyError.unknownError(error)
        }
    }
    
    func handleSummaryFeedback(feedback: DifyMessageRating) async {
        do {
            if self.uid == nil {
                self.uid = try await am.fetchUserInfo()
            }
//            Logger.log(self.messageId)
            guard self.messageId.isEmpty == false else {
                Logger.log("Error: No message ID found")
                return
            }
            
            await sendFeedback(rating: feedback)
        }
        catch {
            
        }
    }
    
    
    private func sendFeedback(rating: DifyMessageRating) async {
        var tmpRequest: URLRequest?
        
        switch self.summaryType {
        case .healthSummary:
            tmpRequest = dm.createMessageFeedbackRequest(messageId: self.messageId, uid: self.uid, apiKey: Secrets.healthSummaryAPIKey, rating: rating, content: nil)
        case .healthMotivator:
            tmpRequest = dm.createMessageFeedbackRequest(messageId: self.messageId, uid: self.uid, apiKey: Secrets.healthMotivatorAPIKey, rating: rating, content: nil)
        case .healthSupporter:
            tmpRequest = dm.createMessageFeedbackRequest(messageId: self.messageId, uid: self.uid, apiKey: Secrets.healthSupporterAPIKey, rating: rating, content: nil)
        default:
            Logger.log("Unsupported appType present", .error)
            return
        }
        
        guard let request = tmpRequest else {
            Logger.log("Creating request failed", .error)
            return
        }
        
//        Logger.log(request.url?.absoluteString ?? "No url found")
        
        dm.handleSession(request: request,
                         onPartialResponse: { partial in
        }, onCompletion: { res in
//            if let feedback = res as? DifyFeedbackResponse {
//                Logger.log("Feedback response gotten: \(feedback)")
//            }
        }, onError: { error in
            Logger.log("\(error)")
            self.error = DifyError.unknownError(error)
        })
    }
    
    
    private func appendBufferedText() {
        if !apiResponseBuffer.isEmpty {
            let combinedText = apiResponseBuffer.joined(separator: "")
            responseText.append(combinedText)
            apiResponseBuffer.removeAll()
        }
    }
    
    static var mock: AISummaryViewModel {
        var vm = AISummaryViewModel(summaryType: .healthSummary)
        
        vm.timerCancellable?.cancel()
        
        vm.responseText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut augue eu tellus condimentum iaculis nec eget nisi. Mauris justo."
        
        return vm
    }
    
}
