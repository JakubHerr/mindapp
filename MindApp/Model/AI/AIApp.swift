//
//  AIApp.swift
//  MindApp
//
//  Created by Jan Gutwirth on 05.03.2025.
//

import Foundation


struct AIApp: Codable, Equatable, Identifiable {
    let id: Int
    let apiUrl: AIAppURL
//    let apiUrlId: Int
    let apiKey: String
    let parameters: [AIAppParameter]
    let localizations: [AIAppLocalization]
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case apiUrl = "ai_app_url"
//        case apiUrlId = "api_url_id"
        case apiKey = "api_key"
        case parameters = "parameters"
        case localizations = "ai_app_localization"
        case iconName = "icon_name"
    }
    
    init(id: Int, apiUrl: AIAppURL, apiKey: String, parameters: [AIAppParameter], localizations: [AIAppLocalization], iconName: String) {
        self.id = id
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.parameters = parameters
        self.localizations = localizations
        self.iconName = iconName
    }
    
    static var mockArray: [AIApp] {
        let a1 = AIApp(id: 1, apiUrl: AIAppURL(id: 1, url: "https://ma-test.infra.csiplus.cz/v1/completion-messages", description: "completion"), apiKey: "app-YfdSRGtw14g71SV3wKAUIQXe", parameters: [AIAppParameter(name: AIAppParameterName.heartData, type: .string, requirement: .required), AIAppParameter(name: AIAppParameterName.language, type: .string, requirement: .optional)], localizations: [AIAppLocalization(locale: .cs, title: "Získejte další poznatky s pomocí AI", description: "Získejte shrnutí svého zdraví s pomocí umělé inteligence"), AIAppLocalization(locale: .en, title: "Get more insights with the help of AI", description: "Get the summary of your health stats with the help of AI")], iconName: "brain.head.profile")
        let a2 = AIApp(id: 2, apiUrl: AIAppURL(id: 1, url: "https://ma-test.infra.csiplus.cz/v1/completion-messages", description: "completion"), apiKey: "app-YfdSRGtw14g71SV3wKAUIQXe", parameters: [AIAppParameter(name: AIAppParameterName.heartData, type: .string, requirement: .optional), AIAppParameter(name: AIAppParameterName.language, type: .string, requirement: .required)], localizations: [AIAppLocalization(locale: .cs, title: "Získejte další poznatky s pomocí AI", description: "Získejte shrnutí svého zdraví s pomocí umělé inteligence"), AIAppLocalization(locale: .en, title: "Get more insights with the help of AI", description: "Get the summary of your health stats with the help of AI")], iconName: "brain.head.profile")
        return [a1, a2]
    }
    
    static var mock: AIApp {
        return AIApp(id: 1, apiUrl: AIAppURL(id: 1, url: "https://ma-test.infra.csiplus.cz/v1/completion-messages", description: "completion"), apiKey: "app-YfdSRGtw14g71SV3wKAUIQXe", parameters: [AIAppParameter(name: AIAppParameterName.heartData, type: .string, requirement: .required), AIAppParameter(name: AIAppParameterName.language, type: .string, requirement: .optional)], localizations: [AIAppLocalization(locale: .cs, title: "Získejte další poznatky s pomocí AI", description: "Získejte shrnutí svého zdraví s pomocí umělé inteligence"), AIAppLocalization(locale: .en, title: "Get more insights with the help of AI", description: "Get the summary of your health stats with the help of AI")], iconName: "brain.head.profile")
    }
}

struct AIAppURL: Codable, Equatable {
    let id: Int
    let url: String
    let description: String
    
    init(id: Int, url: String, description: String) {
        self.id = id
        self.url = url
        self.description = description
    }
}

struct AIAppParameter: Codable, Equatable, Identifiable {
    let id: UUID
    let name: AIAppParameterName
    let type: AIAppParameterType
    let requirement: AIAppParameterRequirement
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case requirement
    }
    
    init(name: AIAppParameterName, type: AIAppParameterType, requirement: AIAppParameterRequirement) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.requirement = requirement
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(AIAppParameterName.self, forKey: .name)
        self.type = try container.decode(AIAppParameterType.self, forKey: .type)
        self.requirement = try container.decode(AIAppParameterRequirement.self, forKey: .requirement)
    }
}

enum AIAppParameterName: String, Codable {
    case heartData = "heartData"
    case language = "language"
    case location = "location"
    case calories = "calories"
    case steps = "steps"
    case age = "age"
    case gender = "gender"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "heartData":
            self = .heartData
        case "language":
            self = .language
        case "location":
            self = .location
        case "calories":
            self = .calories
        case "steps":
            self = .steps
        case "age":
            self = .age
        default:
            throw NSError(domain: "init.AIAppParameterValue", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize AIAppParameterValue due to invalid value", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the String is correctly populated"])
        }
    }
    
    init(from value: String) throws {
        switch value {
        case "heartData":
            self = .heartData
        case "language":
            self = .language
        case "location":
            self = .location
        case "calories":
            self = .calories
        case "steps":
            self = .steps
        case "age":
            self = .age
        default:
            throw NSError(domain: "init.AIAppParameterValue", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize AIAppParameterValue due to invalid value", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the String is correctly populated"])
        }
    }
}

enum AIAppParameterType: String, Codable, Equatable {
    case string = "string"
    case int = "int"
    case bool = "bool"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "string":
            self = .string
        case "int":
            self = .int
        case "bool":
            self = .bool
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid parameter type")
        }
    }
    
    init(from type: String) throws {
        switch type {
        case "string":
            self = .string
        case "int":
            self = .int
        case "bool":
            self = .bool
        default:
            throw NSError(domain: "init.AIAppParameterType", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize AIAppParameterType due to invalid type", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the string is correctly populated"])
        }
    }
}

struct AIAppLocalization: Codable, Equatable {
    let locale: AIAppLocalizationLocale
    let title: String
    let description: String
    
    init(locale: AIAppLocalizationLocale, title: String, description: String) {
        self.locale = locale
        self.title = title
        self.description = description
    }
}

enum AIAppLocalizationLocale: String, Codable, Equatable {
    case cs = "cs"
    case en = "en"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "cs":
            self = .cs
        case "en":
            self = .en
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid locale")
        }
    }
    
    init(from locale: String) throws {
        switch locale {
        case "cs":
            self = .cs
        case "en":
            self = .en
        default:
            throw NSError(domain: "init.AIAppLocalizationLocale", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize AIAppLocalizationLocale due to invalid locale", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the string is correctly populated"])
        }
    }
}


enum AIAppParameterRequirement: String, Codable, Equatable {
    case required = "required"
    case optional = "optional"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "required":
            self = .required
        case "optional":
            self = .optional
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid requirement")
        }
    }
    
    init(from locale: String) throws {
        switch locale {
        case "required":
            self = .required
        case "optional":
            self = .optional
        default:
            throw NSError(domain: "init.AIAppParameterRequirement", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize AIAppParameterRequirement due to invalid requirement", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the String is correctly populated"])
        }
    }
}
