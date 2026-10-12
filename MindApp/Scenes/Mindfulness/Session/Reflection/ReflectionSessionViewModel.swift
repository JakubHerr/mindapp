//
//  AIGuidedDiaryViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 23.11.2024.
//


//
//  ChatWithAIViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 14.10.2024.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ReflectionSessionViewModel: ObservableObject {
    
    @Injected private var dm: DifyManager
    
    @Injected var hm: HealthKitManager
    
    @Injected var am: AuthManager
    
    private var currConversationId: String
    
    private var questionCount: Int
    
    @Published var error: DifyError?
    
    @Published var chat: [Message]
    
    @Published var generating: Bool
    
    @Published var conversationFinished: Bool
    
    var fvm: FormViewModel
    
    var responseString: String
    
    var currQuestionaireIndex: Int
    
    var selectedQuestion: String
    
    private var summary: String
    
    var uid: String?
    var hd: String?
    
    private var isLastRequest: Bool {
        if let last = chat.last {
            if last.getIsRequest() {
                return true
            }
        }
        return false
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var apiResponseBuffer: [String] = []
    
    private var quesCancellables: [AnyCancellable] = []
    
    @Published var isCurrQuestionnaireOpen: Bool = false
    
    init() {
        self.summary = ""
        self.currConversationId = ""
        self.questionCount = 0
        self.chat = []
        self.generating = false
        self.conversationFinished = false
        self.responseString = ""
        self.currQuestionaireIndex = -1
        self.selectedQuestion = ""
        self.fvm = FormViewModel()
        self.fvm.setFinisher(finish: saveEvaluationToHealthApp)
        Timer.publish(every: 0.1, on: .main, in: .common)  // Adjust interval as needed
                    .autoconnect()
                    .sink { [weak self] _ in
                        self?.appendBufferedText()
                    }
                    .store(in: &cancellables)
    }
    
    private func saveEvaluationToHealthApp(evaluation: [FHIRItemBase]) async -> Void{
        do {
            let _ = try await hm.addReflectionResult(startDate: .now, endDate: .now, details: evaluation)
        }
        catch {
            Logger.log("Error saving evaluation to health app: \(error)", .error)
        }
    }
    
    func startSession() async {
        do {
            self.uid = try await am.fetchUserInfo()
            self.hd = await hm.fetchHeartData()
            generateNextResponse()
        }
        catch {
            Logger.log("\(error)", .error)
            self.error = DifyError.unknownError(error)
            self.generating = false
        }
    }
    
    func generateNextResponse(input: String = "start") {
        var entirePrompt: String = ""
        if let lastQuestionaire = self.chat.last as? Questionnaire {
            entirePrompt = "Question: " + lastQuestionaire.getSelectedQuestion().text + "\n" + "Answer: "
        }
        
        entirePrompt += input
        
        var urlRequest: URLRequest?
        urlRequest = dm.createReflectionRequest(input: entirePrompt, conversationId: currConversationId, uid: uid, healthData: hd)
        
        guard let request = urlRequest else {
            Logger.log("Creating request failed", .error)
            self.error = DifyError.invalidRequest
            return
        }
        
        self.generating.toggle()
        
        dm.handleSession(request: request,
                         onPartialResponse: { response in
            if let partialResponse = response as? DifyMessageEventResponse {
                if let lastMsg = self.chat.last as? TextMessage {
                    if !lastMsg.getIsRequest() {
                        lastMsg.appendText(text: partialResponse.answer)
                    }
                    else {
                        self.chat.append(TextMessage(text: partialResponse.answer, isRequest: false))
                    }
                }
            }
        }, onCompletion: { response in
            if let completeResponse = response as? DifyChatCompletionResponse {
                if let responseData = completeResponse.answer.data(using: .utf8) {
                    do {
                        let refResponse = try JSONDecoder().decode(DIfyReflectionResponseEnum.self, from: responseData)
                        Logger.log("Completion response received", .success)
                        switch refResponse {
                        case .evaluation(let evaluation):
                            self.generating = false
                            if evaluation.value.data.count > 1 {
                                Logger.log("Multiple objects in response", .error)
                            }
                            else if let ques = evaluation.value.data.first as? FHIRQuestionnaire {
                                self.fvm.setSteps(steps: ques.item)
                            }
                            self.conversationFinished = true
                            
                        case .questionnaire(let questionnaire):
                            self.generating.toggle()
                            self.currConversationId = completeResponse.conversationId ?? ""
                            self.currQuestionaireIndex = self.chat.count
                            let newQues = Questionnaire(id: completeResponse.messageId, questionnaire: questionnaire)
                            newQues.$isOpen.receive(on: RunLoop.main).sink { [weak self] newVal in
                                withAnimation {
                                    self?.isCurrQuestionnaireOpen = newVal                                    
                                }
                            }.store(in: &self.quesCancellables)
                            self.chat.append(newQues)
                            self.questionCount += 1
                        }
                    }
                    catch {
                        Logger.log("DECODING ERROR: \(error)", .error)
                        self.error = DifyError.jsonDecodingError(error)
                    }
                }
                else {
                    Logger.log("DECODING ERROR: \(String(describing: response))", .error)
                    self.error = DifyError.invalidResponse
                }
            }
            else if let _ = response as? DifyMessageEndEventResponse {
                if let _ = self.chat.last as? TextMessage {
                    self.generating.toggle()
                }
            }
            else {
                Logger.log("Unknown response type", .error)
                self.error = DifyError.invalidResponse
            }
        }, onError: { error in
            Logger.log("\(error)")
            DispatchQueue.main.sync {
                self.error = DifyError.unknownError(error)
            }
        })
    }
    
    private func appendBufferedText() {
        if !apiResponseBuffer.isEmpty {
            let combinedText = apiResponseBuffer.joined(separator: "")
            if let last = chat.last {
                if !last.getIsRequest() {
                    if let textMsg = last as? TextMessage {
                        textMsg.appendText(text: combinedText)
                        apiResponseBuffer.removeAll()  // Clear buffer after appending
                    }
                }
            }
        }
    }
    
    func lockLatestQuestionaire() {
        for message in chat.reversed() {
            if let questionaire = message as? Questionnaire {
                questionaire.isLockedIn = true
            }
        }
    }
    
    static var mock: ReflectionSessionViewModel {
        let vm = ReflectionSessionViewModel()
        vm.chat = [
            TextMessage(text: "Hello", isRequest: true),
            Questionnaire(questions: ["How are you?","Are you ok?","Do you have any plans?"]),
            TextMessage(text: "How are you?", isRequest: true)
        ]
        return vm
    }
    
}



