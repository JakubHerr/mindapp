//
//  RequestResponse.swift
//  MindApp
//
//  Created by Jan Gutwirth on 25.09.2024.
//

import SwiftUI

class Message: Identifiable, Equatable, ObservableObject {
    
    var id: UUID = .init()
    fileprivate var isRequest: Bool = false
    
    init(id: UUID = .init()) {
        self.id = id
    }
    
    func getIsRequest() -> Bool {
        isRequest
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        if lhs.isRequest == rhs.isRequest {
            return true
        }
        return false
    }
}

class TextMessage: Message {
    @Published private var text: String = ""
    
    init(id: UUID = .init(), text: String, isRequest: Bool) {
        super.init(id: id)
        super.isRequest = isRequest
        self.text = text
    }
    
    init(id: String, text: String, isRequest: Bool) {
        super.init(id: UUID(uuidString: id) ?? .init())
        self.isRequest = false
        self.text = text
    }
    
    public func appendText(text: String) {
        self.text += text
    }
    
    public func getText() -> String {
        text
    }
    
    static func == (lhs: TextMessage, rhs: TextMessage) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        if lhs.text == rhs.text {
            return true
        }
        if lhs.isRequest == rhs.isRequest {
            return true
        }
        return false
    }
}

class Questionnaire: Message {
    @Published private var questions: [Question] = []
    private var selectedQuestion: Int = -1
    @Published var isOpen: Bool = false
    @Published var isLockedIn: Bool = false
    
    init(id: UUID = .init(), questions newQuestions: [String]) {
        super.init(id: id)
        
        for question in newQuestions {
            self.questions.append(Question(text: question))
        }
        
        self.selectedQuestion = 0
    }
    
    init(id: String, questionnaire: DifyReflectionQuestionnaire) {
        super.init(id: UUID(uuidString: id) ?? .init())
        
        var tmpQuestions: [Question] = []
        
        for question in questionnaire.value {
            tmpQuestions.append(Question(text: question.text))
        }
        
        self.questions = tmpQuestions
        
        self.selectedQuestion = 0
    }
    
    func setSelectedQuestion(index: Int) {
        if index >= questions.count {
            return
        }
        selectedQuestion = index
    }
    
    func getSelectedQuestionIndex() -> Int {
        return selectedQuestion
    }
    
    func getSelectedQuestion() -> Question {
        return questions[selectedQuestion]
    }
    
    func getQuestions() -> [Question] {
        questions
    }
    
    func setQuestions(questions: [Question]) {
        self.questions = questions
    }
    
    static func == (lhs: Questionnaire, rhs: Questionnaire) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        if lhs.questions == rhs.questions {
            return true
        }
        if lhs.selectedQuestion == rhs.selectedQuestion {
            return true
        }
        if lhs.isLockedIn == rhs.isLockedIn {
            return true
        }
        if lhs.isRequest == rhs.isRequest {
            return true
        }
        return false
    }
    
    static var mock: Questionnaire {
        return Questionnaire(questions: ["Where's Gamora?", "Who's Gamora?", "Why is Gamora?", "LONG QUESTION LONG QUESTION QUESTION LONG IS LONG"])
    }
}

struct Question: Identifiable, Equatable {
    var text: String
    var id: UUID = UUID()
}
