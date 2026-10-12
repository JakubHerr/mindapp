//
//  ReflectionEvaluationView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 13.02.2025.
//

import SwiftUI

struct ReflectionEvaluationView: View {

    @EnvironmentObject var vm: ReflectionEvaluationViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
//            let itemWidth: CGFloat = screenWidth
            let spacing: CGFloat = 0
//            let totalWidth = (itemWidth + spacing) * CGFloat(vm.questions.count) - spacing
            VStack {
                VStack {
                    ProgressView(value: vm.progress, total: 1)
                    Text("\(Int(vm.progress * 100))% there")
                }
                .padding(.vertical, 30)
                
                Spacer()
                
                ScrollViewReader { proxy in
                    ScrollView (.horizontal, showsIndicators: false) {
                        HStack (spacing: spacing) {
                            ForEach(vm.questions.indices, id: \.self) { index in
                                ReflectionQuestionView(question: vm.questions[index])
                                    .environmentObject(vm)
                                    .frame(width: screenWidth - (screenWidth / 4))
                            }
                            
                            Text("Thank you")
                                .id(vm.questions.count)
                                .frame(width: screenWidth)
                        }
                    }
                    .onChange(of: vm.round) { newRound in
                        withAnimation (.easeInOut){
                            proxy.scrollTo(newRound, anchor: .center)
                        }
                    }
                    
                }
                .scrollDisabled(true)
                
                Spacer()
                
                HStack {
                    Button {
                        withAnimation(.easeInOut) {
                            vm.round -= 1
                        }
                    } label: {
                        Text("evaluation_button_previous")
                            .padding()
                            .background(Color.yellow)
                    }
                    .disabled(vm.round == 0)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            vm.round += 1
                        }
                    } label: {
                        Text("evaluation_button_next")
                            .padding()
                            .background(Color.yellow)
                    }
                    .disabled(vm.round == vm.questions.count)
                }
            }
        }
    }
}

#Preview {
    ReflectionEvaluationView()
        .environmentObject(ReflectionEvaluationViewModel.mock)
}
