//
//  ReflectionEvaluationViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 13.02.2025.
//

import Foundation

struct Option: Identifiable {
    let id: UUID = .init()
    let text: String
    let index: Int
}

class ReflectionQuestion: Identifiable, Equatable, ObservableObject {
    

    var id: UUID = UUID()
    
    let question: String
    
    let options: [Option]
    
    @Published var selectedOption: Int
    
    init(question: String, options: [Option], selectedOption: Int) {
        self.question = question
        self.options = options
        self.selectedOption = selectedOption
    }

    static func == (lhs: ReflectionQuestion, rhs: ReflectionQuestion) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        return true
    }
}

class ReflectionEvaluationViewModel: ObservableObject {
    
    
    @Published var questions: [ReflectionQuestion]
    
    @Published var round: Int = 0
    
    var currQuestion: ReflectionQuestion {
        if questions.count > round {
            return questions[round]
        }
        if questions.isEmpty {
            return ReflectionQuestion(question: "", options: [], selectedOption: 0)
        }
        return questions[questions.count - 1]
    }
    
    var progress: Double {
        Double(Double(round) / Double(questions.count))
    }
    
    init(questions: [ReflectionQuestion]) {
        self.questions = []
        for question in questions {
            self.questions.append(question)
        }
        self.questions = questions
    }
    
    func select(option: Int) {
        if currQuestion.options.count > option {
            Logger.log("Error? weird option", .error)
            return
        }
        questions[round].selectedOption = option
    }
    
    func select(option: Int, for question: ReflectionQuestion) {
        if let index = questions.firstIndex(where: { $0.id == question.id }) {
            questions[index].selectedOption = option
        }
        else {
            Logger.log("Question isn't part of the questions", .error)
        }
        
//        if !questions.contains(question) {
//            Logger.log("Question isn't part of the questions", .error)
//            return
//        }
//
//        questions.first(where: { $0.id == question.id })?.selectedOption = option
        
        
    }
    
    public static var mock: ReflectionEvaluationViewModel {
        let q1 = ReflectionQuestion(question: "Question 1?", options: [Option(text: "Option A", index: 0), Option(text: "Option B", index: 1), Option(text: "Option C", index: 2)], selectedOption: .random(in: 0...2))
        let q2 = ReflectionQuestion(question: "Question 2??", options: [Option(text: "Damn, option A", index: 0), Option(text: "Bad option B", index: 1), Option(text: "Worse option C", index: 2), Option(text: "WTF there's option D", index: 3)], selectedOption: .random(in: 0...3))
        let q3 = ReflectionQuestion(question: "Final question?", options: [Option(text: "I don't want option A", index: 0), Option(text: "There's just two options?", index: 1)], selectedOption: .random(in: 0...1))
        return .init(questions: [q1, q2, q3])
    }
    
}
