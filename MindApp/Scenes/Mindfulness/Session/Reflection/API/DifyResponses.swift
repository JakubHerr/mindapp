//
//  DifyMessages.swift
//  MindApp
//
//  Created by Jan Gutwirth on 27.12.2024.
//

import Foundation


//MARK: Responses for `streaming` response mode
enum DifyChunkChatEvent: Codable {
    case message(DifyMessageEventResponse)
    case messageFile(DifyMessageFileEventResponse)
    case messageEnd(DifyMessageEndEventResponse)
    case ttsMessage(DifyTTSMessageEventResponse)
    case ttsMessageEnd(DifyTTSMessageEndEventResponse)
    case messageReplace(DifyMessageReplaceEventResponse)
    case workflowStarted(DifyWorkflowStartedEventResponse)
    case nodeStarted(DifyNodeStartedEventResponse)
    case nodeFinished(DifyNodeFinishedEventResponse)
    case workflowFinished(DifyWorkflowFinishedEventResponse)
    case error(DifyErrorEventResponse)
    case ping(DifyPingEventResponse)

    private enum CodingKeys: String, CodingKey {
        case event
    }

    // Decoding based on the "event" field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let eventType = try container.decode(String.self, forKey: .event)

        switch eventType {
        case "message":
            self = .message(try DifyMessageEventResponse(from: decoder))
        case "message_file":
            self = .messageFile(try DifyMessageFileEventResponse(from: decoder))
        case "message_end":
            self = .messageEnd(try DifyMessageEndEventResponse(from: decoder))
        case "tts_message":
            self = .ttsMessage(try DifyTTSMessageEventResponse(from: decoder))
        case "tts_message_end":
            self = .ttsMessageEnd(try DifyTTSMessageEndEventResponse(from: decoder))
        case "message_replace":
            self = .messageReplace(try DifyMessageReplaceEventResponse(from: decoder))
        case "workflow_started":
            self = .workflowStarted(try DifyWorkflowStartedEventResponse(from: decoder))
        case "node_started":
            self = .nodeStarted(try DifyNodeStartedEventResponse(from: decoder))
        case "node_finished":
            self = .nodeFinished(try DifyNodeFinishedEventResponse(from: decoder))
        case "workflow_finished":
            self = .workflowFinished(try DifyWorkflowFinishedEventResponse(from: decoder))
        case "error":
            self = .error(try DifyErrorEventResponse(from: decoder))
        case "ping":
            self = .ping(try DifyPingEventResponse(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .event, in: container, debugDescription: "Unknown event type: \(eventType)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .message(let message):
            try container.encode("message", forKey: .event)
            try message.encode(to: encoder)
        case .messageFile(let messageFile):
            try container.encode("message_file", forKey: .event)
            try messageFile.encode(to: encoder)
        case .messageEnd(let messageEnd):
            try container.encode("message_end", forKey: .event)
            try messageEnd.encode(to: encoder)
        case .ttsMessage(let ttsMessage):
            try container.encode("tts_message", forKey: .event)
            try ttsMessage.encode(to: encoder)
        case .ttsMessageEnd(let ttsMessageEnd):
            try container.encode("tts_message_end", forKey: .event)
            try ttsMessageEnd.encode(to: encoder)
        case .messageReplace(let messageReplace):
            try container.encode("message_replace", forKey: .event)
            try messageReplace.encode(to: encoder)
        case .workflowStarted(let workflowStarted):
            try container.encode("workflow_started", forKey: .event)
            try workflowStarted.encode(to: encoder)
        case .nodeStarted(let nodeStarted):
            try container.encode("node_started", forKey: .event)
            try nodeStarted.encode(to: encoder)
        case .nodeFinished(let nodeFinished):
            try container.encode("node_finished", forKey: .event)
            try nodeFinished.encode(to: encoder)
        case .workflowFinished(let workflowFinished):
            try container.encode("workflow_finished", forKey: .event)
            try workflowFinished.encode(to: encoder)
        case .error(let error):
            try container.encode("error", forKey: .event)
            try error.encode(to: encoder)
        case .ping(let ping):
            try container.encode("ping", forKey: .event)
            try ping.encode(to: encoder)
        }
    }
}

protocol DifyResponse {}

//MARK: Message Event
struct DifyMessageEventResponse: Codable, DifyResponse {
    let taskId: String
    let id: String
    let conversationId: String?
    let answer: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case conversationId = "conversation_id"
        case answer
        case createdAt = "created_at"
    }
}

//MARK: Message file Event
struct DifyMessageFileEventResponse: Codable, DifyResponse {
    let id: String
    let type: String
    let belongsTo: String
    let url: String
    let conversationId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case belongsTo = "belongs_to"
        case url
        case conversationId = "conversation_id"
    }
}

//MARK: MessageEndEvent
struct DifyMessageEndEventResponse: Codable, DifyResponse {
    let taskId: String
    let id: String
    let conversationId: String?
    let metadata: Metadata
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case conversationId = "conversation_id"
        case metadata
    }
}

struct Metadata: Codable {
    let usage: Usage
    let retrieverResources: [RetrieverResource]?
    
    enum CodingKeys: String, CodingKey {
        case usage
        case retrieverResources = "retriever_resources"
    }
}

struct Usage: Codable {
    let promptTokens: Int
    let promptUnitPrice: String
    let promptPriceUnit: String
    let promptPrice: String
    let completionTokens: Int
    let completionUnitPrice: String
    let completionPriceUnit: String
    let completionPrice: String
    let totalTokens: Int
    let totalPrice: String
    let currency: String
    let latency: Double
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case promptUnitPrice = "prompt_unit_price"
        case promptPriceUnit = "prompt_price_unit"
        case promptPrice = "prompt_price"
        case completionTokens = "completion_tokens"
        case completionUnitPrice = "completion_unit_price"
        case completionPriceUnit = "completion_price_unit"
        case completionPrice = "completion_price"
        case totalTokens = "total_tokens"
        case totalPrice = "total_price"
        case currency
        case latency
    }
}

struct RetrieverResource: Codable {
    let source: String
    let description: String
    let position: Int?
    let datasetId: String?
    let datasetName: String?
    let documentId: String?
    let documentName: String?
    let segmentId: String?
    let score: Double?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case description
        case position
        case datasetId = "dataset_id"
        case datasetName = "dataset_name"
        case documentId = "document_id"
        case documentName = "document_name"
        case segmentId = "segment_id"
        case score
        case content
    }
}

//MARK: TTSMessageEvent

struct DifyTTSMessageEventResponse: Codable, DifyResponse {
    let taskId: String
    let id: String
    let audio: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case audio
        case createdAt = "created_at"
    }
}

//MARK: TTSMEssageEndEvent

struct DifyTTSMessageEndEventResponse: Codable, DifyResponse {
    let taskId: String
    let id: String
    let audio: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case audio
        case createdAt = "created_at"
    }
}

struct DifyMessageReplaceEventResponse: Codable, DifyResponse {
    let taskId: String
    let id: String
    let conversationId: String
    let answer: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case conversationId = "conversation_id"
        case answer
        case createdAt = "created_at"
    }
}

//MARK: Workflow started event
struct DifyWorkflowStartedEventResponse: Codable, DifyResponse {
    let taskId: String
    let workflowRunId: String
    let event: String
    let data: WorkflowStartedData
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case workflowRunId = "workflow_run_id"
        case event
        case data
    }
}

struct WorkflowStartedData: Codable {
    let id: String
    let workflowId: String
    let sequenceNumber: Int
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case workflowId = "workflow_id"
        case sequenceNumber = "sequence_number"
        case createdAt = "created_at"
    }
}

//MARK: NodeStartedEvent
struct DifyNodeStartedEventResponse: Codable, DifyResponse {
    let taskId: String
    let workflowRunId: String
    let event: String
    let data: NodeStartedData

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case workflowRunId = "workflow_run_id"
        case event
        case data
    }
}

struct NodeStartedData: Codable {
    let id: String
    let nodeId: String
    let nodeType: String
    let title: String
    let index: Int
    let predecessorNodeId: String?
//    let inputs: Any //hopefully not needed, don't understand it rn
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case nodeId = "node_id"
        case nodeType = "node_type"
        case title
        case index
        case predecessorNodeId = "predecessor_node_id"
        case createdAt = "created_at"
    }
}


//MARK: NodeFinishedEvent
struct DifyNodeFinishedEventResponse: Codable, DifyResponse {
    let taskId: String
    let workflowRunId: String
    let event: String
    let data: NodeFinishedData
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case workflowRunId = "workflow_run_id"
        case event
        case data
    }
}

struct NodeFinishedData: Codable {
    let id: String
    let nodeId: String
    let title: String
    let index: Int
    let predecessorNodeId: String?
//    let inputs: Any //hopefully not required
//    let processData: Any //hopefully not required
//    let outputs: Any //hopefully not required
    let status: String
    let error: String?
    let elapsedTime: Float?
//    let executionMetadata: Any //hopefully not required
    let createdAt: Int
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case nodeId = "node_id"
        case title
        case index
        case predecessorNodeId = "predecessor_node_id"
        case status
        case error
        case elapsedTime = "elapsed_time"
        case createdAt = "created_at"
    }
}

//MARK: WorkflowFinishedEvent
struct DifyWorkflowFinishedEventResponse: Codable, DifyResponse {
    let taskId: String
    let workflowRunId: String
    let event: String
    let data: WorkflowFinishedData
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case workflowRunId = "workflow_run_id"
        case event
        case data
    }
}

struct WorkflowFinishedData: Codable {
    let id: String
    let workflowId: String
    let status: String
    let error: String?
    let elapsedTime: Float?
    let totalTokens: Int?
    let totalSteps: Int
    let createdAt: Int
    let finishedAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case workflowId = "workflow_id"
        case status
        case error
        case elapsedTime = "elapsed_time"
        case totalTokens = "total_tokens"
        case totalSteps
        case createdAt = "created_at"
        case finishedAt = "finished_at"
    }
}

//MARK: ErrorEvent

struct DifyErrorEventResponse: Codable, DifyResponse {
    let taskId: String
    let id: String
    let status: Int
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case status
        case code
        case message
    }
}

//MARK: Ping

struct DifyPingEventResponse: Codable, DifyResponse {}

//MARK: Responses for `blocking` response mode

struct DifyChatCompletionResponse: Codable, DifyResponse {
    let messageId: String
    let conversationId: String?
    let mode: String
    let answer: String
    let metadata: Metadata
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case conversationId = "conversation_id"
        case mode
        case answer
        case metadata
        case createdAt = "created_at"
    }
}

//MARK: Responses for Reflection chatflow

protocol DifyReflectionResponse: Codable{}

enum DIfyReflectionResponseEnum: Codable {
    case questionnaire(DifyReflectionQuestionnaire)
    case evaluation(DifyReflectionEvaluation)
    
    private enum CodingKeys: String, CodingKey {
        case type
    }

    // Decoding based on the "type" field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "questionnaire":
            self = .questionnaire(try DifyReflectionQuestionnaire(from: decoder))
        case "evaluation":
            self = .evaluation(try DifyReflectionEvaluation(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown event type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .questionnaire(let questionnaire):
            try container.encode("questionnaire", forKey: .type)
            try questionnaire.encode(to: encoder)
        case .evaluation(let evaluation):
            try container.encode("evaluation", forKey: .type)
            try evaluation.encode(to: encoder)
        }
    }
}


struct DifyReflectionQuestionnaire: DifyReflectionResponse {
    let type: String
    let value: [DifyReflectionQuestion]
}

struct DifyReflectionQuestion: Codable {
    let text: String
}

struct DifyReflectionEvaluation: DifyReflectionResponse {
    let type: String
    let value: FHIRJSON
}

struct DifyFeedbackResponse: Codable, DifyResponse {
    let result: String
}
