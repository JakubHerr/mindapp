//
//  DynamicAIAppViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 07.03.2025.
//

import Foundation
import Combine


@MainActor
class DynamicAIAppViewModel: ObservableObject {
    
    @Injected private var dm: DifyManager
    
    @Injected private var hm: HealthKitManager
    
    @Injected private var am: AuthManager
    
    class AIAppParameterOption: ObservableObject, Identifiable {
        var id: UUID = UUID()
        var parameter: AIAppParameter
        @Published var value: Bool
        
        init(parameter: AIAppParameter, value: Bool) {
            self.parameter = parameter
            self.value = value
        }
    }
    
    var title: String
    var description: String
    var url: String
    var key: String
    
    var responseMode: DifyResponseMode {
        if responseModeToggle {
            return .streaming
        }
        return .blocking
    }
    
    @Published var responseModeToggle: Bool
    
    @Published var generating: Bool
    
    private var apiResponseBuffer: [String]
    private var cancellables = Set<AnyCancellable>()
    
    @Published var error: DifyError?
    
    var parameters: [AIAppParameter]
    
    @Published var parameterOptions: [AIAppParameterOption]
    
    @Published var output: String
    @Published var input: String
    
    init(app: AIApp) {
        self.generating = false
        self.apiResponseBuffer = []
        self.responseModeToggle = false
//        self.responseMode = .blocking
        self.title = ""
        self.description = ""
        for loc in app.localizations {
            if loc.locale.rawValue == String(Locale.current.identifier.prefix(2)) {
                self.title = loc.title
                self.description = loc.description
            }
        }
        if self.title.isEmpty {
            self.title = app.localizations.first?.title ?? "No title"
            self.description = app.localizations.first?.description ?? "No description"
        }
        self.url = app.apiUrl.url
        self.key = app.apiKey
        self.parameters = app.parameters
        self.parameterOptions = parameters.map { AIAppParameterOption(parameter: $0, value: true) }
        self.output = ""
        self.input = ""
        
        Timer.publish(every: 0.1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in
                        self?.appendBufferedText()
                    }
                    .store(in: &cancellables)
    }
    
    func runAIApp() async {
        do {
            let parameters = try await populateParameterValues()
            
            let uid: String? = try await am.fetchUserInfo()
            
            guard let request = dm.createAIAppRequest(uid: uid, parameters: parameters, isCompletion: true, responseMode: responseMode, apiURL: url, apiKey: key) else {
                Logger.log("Creating request failed", .error)
                return
            }
            
            dm.handleSession(request: request,
                             onPartialResponse: { partial in
                switch self.responseMode {
                case .streaming:
                    if let msg = partial as? DifyMessageEventResponse {
                        self.apiResponseBuffer.append(msg.answer)
                    }
                case .blocking:
                    Logger.log("got partial response in blocking mode", .error)
                }
            }, onCompletion: { complete in
                if case .blocking = self.responseMode {
                    if let completeResponse = complete as? DifyChatCompletionResponse {
                        self.output = completeResponse.answer
                    }
                }
                self.generating.toggle()

            }, onError: { error in
                Logger.log("Error occurred during communication: \(error)")
                DispatchQueue.main.async {
                    self.error = DifyError.unknownError(error)
                }
            })
            
            self.generating.toggle()
        }
        catch {
            self.error = DifyError.unknownError(error)
        }
    }
    
    private func populateParameterValues() async throws -> [String: Any] {
        var retVal: [String: Any] = [:]
        
        for param in parameterOptions {
            if param.value {
                switch param.parameter.name {
                case .heartData:
                    if param.parameter.type == .string {
                        let data = await hm.fetchHeartData()
                        retVal.updateValue(data ?? "No heart data", forKey: param.parameter.name.rawValue)
                    }
                    else {
                        Logger.log("Can't handle this parameter in this type", .error)
                    }
                case .language:
                    if param.parameter.type == .string {
                        let data = Locale.preferredLanguages.first ?? "English"
                        retVal.updateValue(data, forKey: param.parameter.name.rawValue)
                    }
                    else {
                        Logger.log("Can't handle this parameter in this type", .error)
                    }
                case .steps:
                    if param.parameter.type == .string {
                        let data = try await hm.fetchLast7DaysSteps() ?? "No data"
                        retVal.updateValue(data, forKey: param.parameter.name.rawValue)
                    }
                    else if param.parameter.type == .int {
                        let data = try await hm.fetchAverageStepsLastXDays() ?? 0
                        retVal.updateValue(Int(data), forKey: param.parameter.name.rawValue)
                    }
                case .calories:
                    if param.parameter.type == .string {
                        let data = try await hm.fetchAverageCaloriesLastXDays() ?? 0
                        retVal.updateValue(String(data), forKey: param.parameter.name.rawValue)
                    }
                    else if param.parameter.type == .int {
                        let data = try await hm.fetchAverageCaloriesLastXDays() ?? 0
                        retVal.updateValue(Int(data), forKey: param.parameter.name.rawValue)
                    }
                case .age:
                    if param.parameter.type == .string {
                        let data = try await hm.fetchAge() ?? 0
                        retVal.updateValue(String(data), forKey: param.parameter.name.rawValue)
                    }
                    else if param.parameter.type == .int {
                        let data = try await hm.fetchAge() ?? 0
                        retVal.updateValue(Int(data), forKey: param.parameter.name.rawValue)
                    }
                case .gender:
                    if param.parameter.type == .string {
                        let data = try await hm.fetchSex()?.biologicalSex.rawValue ?? 0
                        switch data {
                        case 0:
                            retVal.updateValue("Unknown", forKey: param.parameter.name.rawValue)
                        case 1:
                            retVal.updateValue("Female", forKey: param.parameter.name.rawValue)
                        case 2:
                            retVal.updateValue("Male", forKey: param.parameter.name.rawValue)
                        default:
                            throw NSError(domain: "populateParameterValues()", code: 1, userInfo: [NSLocalizedDescriptionKey: "Gender value from HK invalid", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the gender is valid"])
                        }
                    }
                default:
                    Logger.log("Can't handle this parameter yet", .error)
                }
            }
        }
        return retVal
    }
    
    private func appendBufferedText() {
        if !apiResponseBuffer.isEmpty {
            let combinedText = apiResponseBuffer.joined(separator: "")
            output += combinedText
            apiResponseBuffer.removeAll()
        }
    }
    
    
    static var mock: DynamicAIAppViewModel {
        return DynamicAIAppViewModel(app: AIApp.mock)
    }
    
}
