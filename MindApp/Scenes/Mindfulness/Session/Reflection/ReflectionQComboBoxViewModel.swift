//
//  ReflectionQComboBoxViewModel.swift
//  MindApp
//
//  Created by Jan Gutwirth on 23.11.2024.
//

import Foundation

class ReflectionQComboBoxViewModel: ObservableObject {
    
    private var questions: [Question] = []

    @Published var selectedIndex: Int = -1
    
    @Published var selectedQuestion: String = "No questions available"
    
    func getQuestions() -> [Question] {
        return questions
    }
    
    func addQuestion(question: String) {
        if questions.count == 0 {
            selectedIndex = 0
            selectedQuestion = question
        }
        questions.append(Question(text: question))
    }
    
    func setQuestion(index: Int, question: String) {
        if index >= questions.count {
            Logger.log("Index out of bounds")
            return
        }
        questions[index].text = question
        if index == selectedIndex {
            selectedQuestion = question
        }
    }
    
    func setSelectedQuestion(index: Int) {
        if index >= questions.count {
            Logger.log("Index out of bounds")
            return
        }
        selectedIndex = index
        selectedQuestion = questions[selectedIndex].text
    }
    
    func clearQuestions() {
        questions.removeAll()
        selectedIndex = -1
        selectedQuestion = "No questions available"
    }
    
    func setQuestionaire(questionaire: Questionnaire) {
        for question in questionaire.getQuestions() {
            addQuestion(question: question.text)
        }
    }
    
}
