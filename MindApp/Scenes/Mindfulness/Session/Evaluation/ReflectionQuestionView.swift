//
//  ReflectionQuestionView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 13.02.2025.
//

import SwiftUI

struct ReflectionQuestionView: View {
    
    @ObservedObject var question: ReflectionQuestion
    
    private let rowHeight: CGFloat = 40
    
    @EnvironmentObject var vm: ReflectionEvaluationViewModel
    
    var isOnRound: Bool {
        question.id == vm.currQuestion.id
    }
    
    private var height: CGFloat {
        rowHeight * CGFloat(question.options.count)
    }
            
    var body: some View {
        //        GeometryReader { geometry in
        //            let height = rowHeight * CGFloat(question.options.count)
        List {
            ForEach(question.options, id: \.id) { option in
                self.makeButton(option: option)
            }
            //                .frame(height: rowHeight)
        }
        .scrollDisabled(true)
        //        .padding()
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .opacity(isOnRound ? 1 : 0.5)
        //            .overlay(RoundedRectangle(cornerRadius: 15))
        .shadow(color: isOnRound ? Color.green : Color.red, radius: 20)
        //            .clipShape(RoundedRectangle(cornerRadius: ))
        //            .frame(idealHeight: height)
        //            .fixedSize(horizontal: false, vertical: true)
        //            .frame(height: height)
        //            .frame(height: height)
        //            .frame(maxHeight: height)
        .border(.red)
        //        }
    }
    
    func makeButton(option: Option) -> some View {
        Button(action: {
            question.selectedOption = option.index
//            print("\(height)")
//            print("Selected: \(option.text)")
        }) {
            HStack {
                Image(systemName: self.question.selectedOption == option.index ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(Color.white)
                Text(option.text)
                    .foregroundColor(Color.white)
                    .font(.appSenBody)
            }
        }
        .listRowBackground(self.question.selectedOption == option.index ? Color.appButtonOptionSelected : Color.appButtonOption)
        .frame(height: max(0, rowHeight))
        .disabled(!isOnRound)
    }
}

#Preview {
    let vm = ReflectionEvaluationViewModel.mock
    ReflectionQuestionView(question: vm.currQuestion)
        .environmentObject(vm)
    ReflectionQuestionView(question: vm.questions[1])
        .environmentObject(vm)
}
