//
//  ReflectionQuestionComboBoxView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 23.11.2024.
//

import SwiftUI

struct ReflectionQuestionComboBoxView: View {
    
    @StateObject private var vm: ReflectionQComboBoxViewModel = ReflectionQComboBoxViewModel()
    
    @EnvironmentObject var questionnaire: Questionnaire
            
    @State var isDisabled: Bool = false

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    questionnaire.isOpen.toggle()
                }
            }, label: {
                HStack {
                    Text(vm.selectedQuestion)
                        .foregroundStyle(Color.appTextBody)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 5.0)
                    arrowDownButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.appBackgroundGreenMain)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color.appButtonAccent)
                )
            })
            .disabled(questionnaire.isLockedIn)
            if questionnaire.isOpen && !isDisabled {
                ForEach(Array(vm.getQuestions().enumerated()), id: \.1.id) { index, question in
                    if index != vm.selectedIndex {
                        Button(action: {
                            withAnimation {
                                vm.setSelectedQuestion(index: index)
                                questionnaire.setSelectedQuestion(index: index)
                                questionnaire.isOpen.toggle()
                            }
                        }, label: {
                            HStack {
                                Text(question.text)
                                    .foregroundStyle(Color.appTextBody)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.appBackgroundGreenMain)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(Color.appButtonOption)
                            )
                        })
                        .disabled(questionnaire.isLockedIn)
                    }
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(1)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 1)
        .opacity(questionnaire.isLockedIn ? 0.5 : 1)
        .onAppear {
            vm.setQuestionaire(questionaire: questionnaire)
        }
    }
    
    var arrowDownButton: some View {
        Image(systemName: "chevron.down")
            .rotationEffect(questionnaire.isOpen ? .degrees(180) : .degrees(0))
            .foregroundStyle(Color.appButtonAccent)
    }
    
    func setDisabled(disabled: Bool) {
        self.isDisabled = disabled
    }
    
    func addQuestion(question: String) {
        vm.addQuestion(question: question)
    }
    
    
    
}

#Preview {
    ReflectionQuestionComboBoxView()
        .environmentObject(Questionnaire.mock)
}
