//
//  FormSteps.swift
//  MindApp
//
//  Created by Jan Gutwirth on 14.02.2025.
//

import Foundation

class FHIRJSON: ObservableObject, Codable {
    @Published var data: [FHIRBase]
    
    init(data: [FHIRBase]) {
        self.data = data
    }
    
    enum CodingKeys: String, CodingKey {
        case resourceType
    }
    
    required init(from decoder: Decoder) throws {
        self.data = []
        
        if var container = try? decoder.unkeyedContainer() {
            while !container.isAtEnd {
                let subDecoder = try container.superDecoder() // Get a decoder for this object
                let tempContainer = try subDecoder.container(keyedBy: FHIRBase.CodingKeys.self)
                
                if let resourceType = try? tempContainer.decode(String.self, forKey: .resourceType) {
                    print("Decoding resourceType: \(resourceType)") // Debug output
                    
                    switch resourceType {
                    case "Questionnaire":
                        let questionnaire = try FHIRQuestionnaire(from: subDecoder)
                        self.data.append(questionnaire)
                    default:
                        print("Skipping unknown resourceType: \(resourceType)")
                    }
                }
            }
        }
        else {
            let tempContainer = try decoder.container(keyedBy: FHIRBase.CodingKeys.self)
            
            if let resourceType = try? tempContainer.decode(String.self, forKey: .resourceType) {
                print("Decoding resourceType: \(resourceType)") // Debug output
                
                switch resourceType {
                case "Questionnaire":
                    let questionnaire = try FHIRQuestionnaire(from: decoder)
                    self.data.append(questionnaire)
                default:
                    print("Skipping unknown resourceType: \(resourceType)")
                    self.data = []
                }
            }
        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for resource in data {
            try container.encode(resource)
        }
    }
    
}

class FHIRBase: ObservableObject, Codable {
    @Published var resourceType: String

    enum CodingKeys: String, CodingKey {
        case resourceType
    }

    init(resourceType: String) {
        self.resourceType = resourceType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resourceType = try container.decode(String.self, forKey: .resourceType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resourceType, forKey: .resourceType)
    }
}

class FHIRQuestionnaire: FHIRBase {
    @Published var id: String
    @Published var status: FHIRStatus
    @Published var item: [FHIRItemBase]
    
    enum QuestionnaireCodingKeys: String, CodingKey {
        case id, status, item
    }
    
    init(id: String, status: FHIRStatus, item: [FHIRItemBase]) {
        self.id = id
        self.status = status
        self.item = item
        super.init(resourceType: "Questionnaire")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QuestionnaireCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.status = try container.decode(FHIRStatus.self, forKey: .status)
        
        var rawItemsContainer = try container.nestedUnkeyedContainer(forKey: .item)
        var decodedItems: [FHIRItemBase] = []
        
        while !rawItemsContainer.isAtEnd {
            let subDecoder = try rawItemsContainer.superDecoder()
            let tempContainer = try subDecoder.container(keyedBy: FHIRItemBase.CodingKeys.self)
            
            if let type = try? tempContainer.decode(String.self, forKey: .type) {
                switch type {
                case "boolean":
                    let booleanItem = try FHIRBooleanItem(from: subDecoder)
                    decodedItems.append(booleanItem)
                case "integer":
                    let integerItem = try FHIRIntegerItem(from: subDecoder)
                    decodedItems.append(integerItem)
                case "choice":
                    let choiceItem = try FHIRChoiceItem(from: subDecoder)
                    decodedItems.append(choiceItem)
                case "text":
                    let textItem = try FHIRTextItem(from: subDecoder)
                    decodedItems.append(textItem)
                default:
                    print("Skipping unknown item type: \(type)")
                }
            }
        }
        
        self.item = decodedItems
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: QuestionnaireCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
        
        var itemsContainer = container.nestedUnkeyedContainer(forKey: .item)
        for item in item {
            try itemsContainer.encode(item)
        }
        
        try super.encode(to: encoder)
    }
}


class FHIRItemBase: ObservableObject, Codable, Equatable {
    @Published var type: String
    @Published var linkId: String
    @Published var text: String
    @Published var variableName: String?

    enum CodingKeys: String, CodingKey {
        case type, linkId, text, variableName = "variable"
    }
    
    init(type: String, linkId: String, text: String, variableName: String? = nil) {
        self.type = type
        self.linkId = linkId
        self.text = text
        self.variableName = variableName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.linkId = try container.decode(String.self, forKey: .linkId)
        self.text = try container.decode(String.self, forKey: .text)
        self.variableName = try container.decodeIfPresent(String.self, forKey: .variableName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(linkId, forKey: .linkId)
        try container.encode(text, forKey: .text)
        try container.encode(variableName, forKey: .variableName)
    }
    
    static func == (lhs: FHIRItemBase, rhs: FHIRItemBase) -> Bool {
        if lhs.linkId != rhs.linkId {
            return false
        }
        return true
    }
    
    public func printSelected() {}
}

class FHIRTextItem: FHIRItemBase {
    
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: .value)
        try super.init(from: decoder)
    }
    
    init(linkId: String, text: String, value: String, variableName: String? = nil) {
        self.value = value
        super.init(type: "text", linkId: linkId, text: text, variableName: variableName)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try super.encode(to: encoder)
    }
    
}

class FHIRBooleanItem: FHIRItemBase {
    @Published var selected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case selected
    }

    init(linkId: String, text: String) {
        super.init(type: "boolean", linkId: linkId, text: text)
    }
    
    init(linkId: String, text: String, selected: Bool) {
        self.selected = selected
        super.init(type: "boolean", linkId: linkId, text: text)
    }
    
    init(linkId: String, text: String, variableName: String? = nil, selected: Bool) {
        self.selected = selected
        super.init(type: "boolean", linkId: linkId, text: text, variableName: variableName)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selected = try container.decodeIfPresent(Bool.self, forKey: .selected)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selected, forKey: .selected)
        try super.encode(to: encoder)
    }
    
    override func printSelected() {
        print(selected ?? "Nil")
    }
}

class FHIRIntegerItem: FHIRItemBase {
    @Published var unit: String?
    @Published var selected: Int?

    enum IntegerCodingKeys: String, CodingKey {
        case unit, selected
    }

    init(linkId: String, text: String, unit: String? = nil) {
        self.unit = unit
        super.init(type: "integer", linkId: linkId, text: text)
    }
    
    init(linkId: String, text: String, unit: String? = nil, selected: Int) {
        self.unit = unit
        self.selected = selected
        super.init(type: "integer", linkId: linkId, text: text)
    }
    
    init(linkId: String, text: String, unit: String? = nil, selected: Int, variableName: String? = nil) {
        self.unit = unit
        self.selected = selected
        super.init(type: "integer", linkId: linkId, text: text, variableName: variableName)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntegerCodingKeys.self)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        self.selected = try container.decodeIfPresent(Int.self, forKey: .selected)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func printSelected() {
        print(selected ?? "Nil")
    }
}

class FHIRChoiceItem: FHIRItemBase {
    @Published var answerOption: [FHIRChoiceItemOption]
    @Published var selected: [FHIRChoiceItemOption]
    let multipleChoice: Bool

    enum ChoiceCodingKeys: String, CodingKey {
        case answerOption, selected, multipleChoice
    }

    init(linkId: String, text: String, answerOption: [FHIRChoiceItemOption]) {
        self.answerOption = answerOption
        self.multipleChoice = false
        self.selected = []
        super.init(type: "choice", linkId: linkId, text: text)
    }
    
    init(linkId: String, text: String, answerOption: [FHIRChoiceItemOption], selected: [FHIRChoiceItemOption]) {
        self.answerOption = answerOption
        self.selected = selected
        if selected.count > 1 {
            self.multipleChoice = true
        }
        else {
            self.multipleChoice = false
        }
        super.init(type: "choice", linkId: linkId, text: text)
    }
    
    init(linkId: String, text: String, answerOption: [FHIRChoiceItemOption], selected: [FHIRChoiceItemOption], variableName: String? = nil) {
        self.answerOption = answerOption
        self.selected = selected
        if selected.count > 1 {
            self.multipleChoice = true
        }
        else {
            self.multipleChoice = false
        }
        super.init(type: "choice", linkId: linkId, text: text, variableName: variableName)
    }
    
    init(linkId: String, text: String, answerOption: [FHIRChoiceItemOption], selected: [FHIRChoiceItemOption], multipleChoice: Bool) {
        self.answerOption = answerOption
        self.selected = selected
        if selected.count > 1 {
            if multipleChoice {
                self.multipleChoice = multipleChoice
            }
            else {
                fatalError("Can't have multiple selected choices in non-multiple-choice item")
            }
        }
        else {
            self.multipleChoice = multipleChoice
        }
        super.init(type: "choice", linkId: linkId, text: text)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChoiceCodingKeys.self)
        self.answerOption = try container.decode([FHIRChoiceItemOption].self, forKey: .answerOption)
        if let singleValue = try container.decodeIfPresent(FHIRChoiceItemOption.self, forKey: .selected) {
            self.selected = [singleValue]
            self.multipleChoice = false
        } else if let multipleValues = try container.decodeIfPresent([FHIRChoiceItemOption].self, forKey: .selected) {
            self.selected = multipleValues
            self.multipleChoice = true
        } else {
            self.selected = []
            self.multipleChoice = try container.decodeIfPresent(Bool.self, forKey: .multipleChoice) ?? false
        }
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChoiceCodingKeys.self)
        try container.encode(answerOption, forKey: .answerOption)
        try super.encode(to: encoder)
    }
    
    override func printSelected() {
        print("selected: {")
        for s in selected {
            print(s.valueString)
        }
        print("}")
    }
}

struct FHIRChoiceItemOption: Codable, Hashable, Equatable {
    let id: UUID = .init()
    let valueString: String
    
    enum CodingKeys: String, CodingKey {
        case valueString
    }
    
    init(valueString: String) {
        self.valueString = valueString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.valueString = try container.decode(String.self, forKey: .valueString)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(valueString, forKey: .valueString)
    }
    
    static func == (lhs: FHIRChoiceItemOption, rhs: FHIRChoiceItemOption) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        return true
    }
    
}

enum FHIRStatus: String, Codable {
    case active
    case passive //?? not sure about this one
}

class Loader {
    public static func loadJSON<T: Decodable>(filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ JSON file not found in Resources")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ JSON decoding error:", error)
            return nil
        }
    }
}
