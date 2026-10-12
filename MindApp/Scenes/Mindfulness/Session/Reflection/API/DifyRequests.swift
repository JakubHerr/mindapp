//
//  DifyRequests.swift
//  MindApp
//
//  Created by Jan Gutwirth on 27.01.2025.
//

import Foundation

enum DifyResponseMode: String, Codable {
    case streaming = "streaming"
    case blocking = "blocking"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "streaming":
            self = .streaming
        case "blocking":
            self = .blocking
        default:
            throw NSError(domain: "init.DifyResponseMode", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize DifyResponseMode due to invalid value", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the String is correctly populated"])
        }
    }
}

protocol DifyRequest: Encodable {}

struct CustomCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

class DifyRequestBase: DifyRequest {
    var user: String = "unknown"
    var responseMode: DifyResponseMode = .streaming
    var inputs: [String: Any]?
    
    init(user: String, responseMode: DifyResponseMode = .streaming, inputs: [String : Any]? = nil) {
        self.user = user
        self.responseMode = responseMode
        self.inputs = inputs
    }
    
    init(user: String, inputs: [String : Any]?) {
        self.user = user
        self.inputs = inputs
    }
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case responseMode = "response_mode"
        case user
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responseMode, forKey: .responseMode)
        try container.encode(user, forKey: .user)
        if let inputs = inputs {
            var inputsContainer = container.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .inputs)
            
            for (key, value) in inputs {
                if let stringVal = value as? String {
                    try inputsContainer.encode(stringVal, forKey: CustomCodingKeys(stringValue: key))
                }
                else if let intVal = value as? Int {
                    try inputsContainer.encode(intVal, forKey: CustomCodingKeys(stringValue: key))
                }
                else {
                    throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [CustomCodingKeys(stringValue: key)], debugDescription: "Value is not a String or Int"))
                }
            }
        }
        else {
            let inputNil: [String: String]? = nil
            try container.encode(inputNil, forKey: .inputs)
        }
    }
}


class DifyCompletionRequest: DifyRequestBase {
//    override init(user: String, inputs: [String : String]?) {
//        super.
//    }
}

class DifyChatflowRequest: DifyRequestBase {
    var query: String
    var conversationId: String
    
    enum CodingKeys: String, CodingKey {
        case query
        case conversationId = "conversation_id"
    }
    
    init(user: String, conversationId: String, query: String, responseMode: DifyResponseMode, inputs: [String: String]? = nil) {
        self.conversationId = conversationId
        self.query = query
        super.init(user: user, responseMode: responseMode, inputs: inputs)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        try container.encode(conversationId, forKey: .conversationId)
        try super.encode(to: encoder)
    }
}

class DifyFeedbackRequest: Encodable, DifyRequest {
    let rating: DifyMessageRating
    let user: String
    let content: String
    
    init(rating: DifyMessageRating, user: String, content: String) {
        self.rating = rating
        self.user = user
        self.content = content
    }
    
    enum CodingKeys: String, CodingKey {
        case rating
        case user
        case content
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rating.rawValue, forKey: .rating)
        try container.encode(user, forKey: .user)
        try container.encode(content, forKey: .content)
    }
}
