//
//  DifyManager.swift
//  MindApp
//
//  Created by Jan Gutwirth on 23.12.2024.
//

import Foundation
import Auth

enum DifyError: Error {
    case invalidResponse
    case invalidRequest
    case invalidData
    case dataConversionError
    case unknownError(Error)
    case jsonDecodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "error_invalid_response"
        case .invalidRequest:
            return "error_invalid_request"
        case .invalidData:
            return "error_invalid_data"
        case .dataConversionError:
            return "error_data_conversion"
        case .jsonDecodingError(let error), .unknownError(let error):
            return error.localizedDescription
        }
    }
}

protocol DifyEndpoint {
    var url: URL { get }
    var apiKey: String { get }
}

enum DifyAppType {
    case healthSummary
    case healthMotivator
    case healthSupporter
    case reflection
}

class DifyPresetApp: DifyEndpoint {
    
    let type: DifyAppType
    
    var url: URL {
        switch type {
        case .reflection:
            return URL(string: Secrets.reflectionURL)!
        case .healthSummary:
            return URL(string: Secrets.healthSummaryURL)!
        case .healthMotivator:
            return URL(string: Secrets.healthMotivatorURL)!
        case .healthSupporter:
            return URL(string: Secrets.healthSupporterURL)!
        }
    }
    
    var apiKey: String {
        switch type {
        case .reflection:
            return Secrets.reflectionAPIKey
        case .healthSummary:
            return Secrets.healthSummaryAPIKey
        case .healthMotivator:
            return Secrets.healthMotivatorAPIKey
        case .healthSupporter:
            return Secrets.healthSupporterAPIKey
        }
    }
    
    init(type: DifyAppType) {
        self.type = type
    }
}

class AnyDifyEndpoint: DifyEndpoint {
    var url: URL
    var apiKey: String
    
    init(url: String, apiKey: String) {
        self.url = URL(string: url)!
        self.apiKey = apiKey
    }
}

enum DifyMessageRating: String {
    case upvote = "like"
    case downvote = "dislike"
    case revokeUpvote = "null"
}


/// Manager class for `Dify` app / API cooperation
class DifyManager {
    static let shared = DifyManager()
    
    /// Function to create an `URLRequest` containing the provided data and based on the type of app from `Dify` as mentioned in description of `AppType`
    /// - Parameters:
    ///   - jsonData: Data to be contained in the `URLRequest` in the `Data` format
    ///   - appType: A specified type of `Dify` app, from which the URL and API keys are derived
    /// - Returns: The created `URLRequest` containing all the necessary data
    private func createURLRequest(jsonData: Data, difyEndpoint: DifyEndpoint) -> URLRequest {
        var request = URLRequest(url: difyEndpoint.url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(difyEndpoint.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        return request
    }
    
    
    /// Function that encodes the API Request into `Data` format
    /// - Parameter request: The ``DifyRequest`` to be encoded into `Data`
    /// - Returns: The provided request encoded into `Data` type
    private func encodePayload(request: DifyRequest) -> Data? {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            Logger.log("Failed to encode request payload",.error)
            return nil
        }
        return jsonData
    }
    
    func createHealthSummaryRequest(type: DifyAppType, uid: String?, heartData: String?, calories: String?, steps: String?, age: String?) -> URLRequest? {
        let dcr = DifyCompletionRequest(user: uid ?? "unknown",
                                        responseMode: .streaming,
                                        inputs: ["heartData" : heartData ?? "none",
                                                 "calories" : calories ?? "none",
                                                 "steps" : steps ?? "none",
                                                 "age" : age ?? "none",
                                                 "language" : Locale.preferredLanguages.first ?? "English"])
        
        guard let jsonData = encodePayload(request: dcr) else {
            return nil
        }
        
        return createURLRequest(jsonData: jsonData, difyEndpoint: DifyPresetApp(type: type))
    }
    
    func createAIAppRequest(input: String = "", uid: String?, conversationId: String = "", parameters: [String: Any], isCompletion: Bool, responseMode: DifyResponseMode, apiURL: String, apiKey: String) -> URLRequest? {
        let dr: DifyRequest
        if isCompletion {
            dr = DifyCompletionRequest(user: uid ?? "unknown", responseMode: responseMode, inputs: parameters)
        }
        else {
            dr = DifyChatflowRequest(user: uid ?? "unknown", conversationId: conversationId, query: input, responseMode: responseMode)
        }
        
        guard let jsonData = encodePayload(request: dr) else {
            return nil
        }
        
//        Logger.log("Data encoded")
//        return createURLRequest(jsonData: jsonData, apiKey: apiKey, apiURL: apiURL)
        return createURLRequest(jsonData: jsonData, difyEndpoint: AnyDifyEndpoint(url: apiURL, apiKey: apiKey))
    }
    
    func createMessageFeedbackRequest(messageId: String, uid: String?, apiKey: String, rating: DifyMessageRating, content: String?) -> URLRequest? {
        let dr = DifyFeedbackRequest(rating: rating, user: uid ?? "unknown", content: content ?? "No content")
        
        guard let jsonData = encodePayload(request: dr) else {
            return nil
        }
        
//        Logger.log("Data encoded")
        
//        return createURLRequest(jsonData: jsonData, apiKey: Secrets.difyMessageRatingURL(messageId: messageId), apiURL: <#T##String#>)
        return createURLRequest(jsonData: jsonData, difyEndpoint: AnyDifyEndpoint(url: Secrets.difyMessageRatingURL(messageId: messageId), apiKey: apiKey))
    }
    
    /// Function for creating API requests for AI guided reflection
    /// - Parameters:
    ///   - input: The input that the user specified (if any was specified) in the conversation
    ///   - conversationId: The ID of the current conversation (if any was specified)
    ///   - responseMode: The `Dify` API response mode - by default `blocking`, can also be `streaming`
    /// - Returns: The created `URLRequest` for the reflection app on `Dify`
    func createReflectionRequest(input: String = "start", conversationId: String = "", responseMode: DifyResponseMode = .blocking, uid: String?, healthData: String?) -> URLRequest? {
        Logger.log("Creating reflection request")
        let dcr = DifyChatflowRequest(user: uid ?? "unknown",
                                      conversationId: conversationId,
                                      query: input,
                                      responseMode: responseMode,
                                      inputs: ["language" : Locale.preferredLanguages.first ?? "English"])
        
        guard let jsonData = encodePayload(request: dcr) else {
            return nil
        }
        
//        Logger.log("Data encoded")
//        print(jsonData)
//        return createURLRequest(jsonData: jsonData, appType: .chatflow)
        return createURLRequest(jsonData: jsonData, difyEndpoint: DifyPresetApp(type: .reflection))
    }
    
    /// Function that starts off the URL session
    /// - Parameters:
    ///   - request: The `URLRequest` to be sent
    ///   - onPartialResponse: What should happen when partial response (in case of `streaming` response type) was received from API
    ///   - onCompletion: What should happen when either the response has gotten to its end (e.g. at the end of `streaming` response type response) or if the whole response was received (in `blocking` response type mode)
    func handleSession(request: URLRequest, onPartialResponse: @escaping (DifyResponse) -> Void, onCompletion: @escaping (DifyResponse?) -> Void, onError: @escaping (Error) -> Void) {
//        print("Creating session")
        
        DifyNetworkManager.shared.startStreamingRequest(
            with: request,
            onPartialResponse: { response in
                onPartialResponse(response)
            },
            onCompletion: { final in
                if let difyResponse = final as? DifyResponse? {
                    onCompletion(difyResponse)
                }
            },
            onError: { error in
                onError(error)
            }
        )
    }
    
}


// Custom URLSessionDelegate to handle streaming responses so that the UI doesn't lag when refreshed repeatedly
class DifyStreamingDelegate: NSObject, URLSessionDataDelegate {
    private let onResponseReceived: (DifyResponse) -> Void
    private let onError: (Error) -> Void
    
    init(onResponseReceived: @escaping (DifyResponse) -> Void, onError: @escaping (Error) -> Void) {
        self.onResponseReceived = onResponseReceived
        self.onError = onError
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !data.isEmpty else {
            print("🔁 Keep-alive or empty chunk received")
            return
        }
        guard let rawString = String(data: data, encoding: .utf8) else {
//            Logger.log("Failed to convert Data to String", .error)
//            onError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to convert Data to String")))
            onError(DifyError.dataConversionError)
            return
        }
        
        let jsonLines = rawString.split(separator: "\n\n")
        
        for line in jsonLines {
            // Check for "data:" prefix and extract JSON
            guard let jsonStartRange = line.range(of: "data:")?.upperBound else {
//                print("No 'data:' prefix found ==> working as if got a complete response in blocking response mode")
                
                let jsonString = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if jsonString == "event: ping" {
                    onResponseReceived(DifyPingEventResponse())
                    continue
                }
                guard let jsonData = jsonString.data(using: .utf8) else {
                    //                        Logger.log("Failed to convert JSON String back to Data", .error)
                    //                        onError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to convert JSON String back to Data")))
                    onError(DifyError.invalidData)
                    return
                }
                
                if let event = try? JSONDecoder().decode(DifyChatCompletionResponse.self, from: jsonData) {
                    
                    Logger.log("Event decoded")
                    onResponseReceived(event)
                }
                
                else if let feedbackResult = try? JSONDecoder().decode(DifyFeedbackResponse.self, from: jsonData) {
                    //                        Logger.log("Feedback result gotten")
                    onResponseReceived(feedbackResult)
                }
//                do {
//                }
//                catch {
////                    Logger.log("An error occurred \(error)",.error)
//                    onError(DifyError.jsonDecodingError(error))
//                }
                return
            }
            
            let jsonString = line[jsonStartRange...].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Convert JSON String back to Data
            guard let jsonData = jsonString.data(using: .utf8) else {
//                Logger.log("Failed to convert JSON String back to Data", .error)
//                onError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to convert JSON String back to Data")))
                onError(DifyError.dataConversionError)
                return
            }
            
            
            do {
//                print(String(data: jsonData, encoding: .utf8))
                let event = try JSONDecoder().decode(DifyChunkChatEvent.self, from: jsonData)
                
                if case .message(let messageEvent) = event {
                    onResponseReceived(messageEvent)
                }
                else if case .messageEnd(let messageEndEvent) = event {
                    onResponseReceived(messageEndEvent)
                }
            } catch {
//                print("Failed to decode JSON: \(error)")
//                Logger.log("Failed to decode JSON: \(error)", .error)
                onError(DifyError.invalidData)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                let nsError = error as NSError

                // Handle offline errors
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case NSURLErrorNotConnectedToInternet:
                        onError(DifyError.unknownError(NSError(domain: "NetworkError", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "No Internet connection. Please check your network."])))
                    case NSURLErrorTimedOut:
                        onError(DifyError.unknownError(NSError(domain: "NetworkError", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "The request timed out."])))
                    case NSURLErrorCannotConnectToHost:
                        onError(DifyError.unknownError(NSError(domain: "NetworkError", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "Cannot connect to the server."])))
                    default:
                        onError(error)
                    }
                } else {
                    // Other unknown errors
                    onError(error)
                }
            }
        }
}


class DifyNetworkManager {
    static let shared = DifyNetworkManager()

    private var session: URLSession?

    private init() {}

    func startStreamingRequest(
        with request: URLRequest,
        onPartialResponse: @escaping (DifyMessageEventResponse) -> Void,
        onCompletion: @escaping (Any?) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        let delegate = DifyStreamingDelegate(
            onResponseReceived: { response in
                DispatchQueue.main.async {
                    if let partial = response as? DifyMessageEventResponse {
                        onPartialResponse(partial)
                    }
                    if let _ = response as? DifyMessageEndEventResponse {
                        onCompletion(nil)
                    }
                    if let full = response as? DifyChatCompletionResponse {
                        onCompletion(full)
                    }
                    if let feedback = response as? DifyFeedbackResponse {
                        onCompletion(feedback)
                    }
                }
            },
            onError: { error in
                Logger.log("Error occurred: \(error)", .error)
                onError(error)
            }
        )

        // Create a fresh session with this delegate
        let session = URLSession(
            configuration: .default,
            delegate: delegate,
            delegateQueue: nil
        )
        self.session = session // Optional: store it if you need to cancel or reuse

        let task = session.dataTask(with: request)
        task.resume()
    }
}
