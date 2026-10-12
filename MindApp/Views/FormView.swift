//
//  FormStepView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 14.02.2025.
//

import SwiftUI

struct FormView: View {
    @EnvironmentObject var vm: FormViewModel
    @EnvironmentObject var router: NavPathRouter
    
    var body: some View {
        ZStack {
//            BackgroundGradientView()
            Color.appSessionBackground.ignoresSafeArea()
//            Color.appAccentGreenDark.ignoresSafeArea()
            
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let spacing: CGFloat = 0
                VStack {
                    progress
                    
                    Spacer()
                    
                    formSteps(screenWidth: screenWidth, spacing: spacing)
                    
                    Spacer()
                    
                    HStack {
                        makeButton(of: .previous, screenWidth: screenWidth)
                        makeButton(of: .next, screenWidth: screenWidth)
                    }
                }
            }
        }
    }
    
    var progress: some View {
//        VStack {
//            ProgressView(value: vm.progress, total: 1)
//            Text("\(Int(vm.progress * 100))%_there")
//        }
        CustomProgressView(step: Float(vm.round), totalSteps: Float(vm.steps.count), color: .white)
            .padding(.vertical, 30)
            .padding(.horizontal)
    }
    
    private func formSteps(screenWidth: CGFloat, spacing: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: spacing) {
                    ForEach(vm.steps.indices, id: \.self) { index in
                        FormStepView(step: vm.steps[index])
                            .environmentObject(vm)
                            .frame(width: screenWidth /*- (screenWidth / 4)*/)
                    }
                    
                    VStack(spacing: 50) {
                        Text("thank_you_evaluation_end_text")
                            .font(.appSenTitle)
                            .foregroundStyle(Color.appTextBody)
                        
                        Button {
                            Task {
                                await vm.finish(vm.steps)
                                vm.finished = true
                                router.navigateToRoot()
                            }
                        } label: {
                            Text("finish_session_button")
                                .font(.appSenBody)
                                .foregroundStyle(Color.appTextBody)
                                .padding()
                                .background(Color.appButtonMain)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(color: Color.green, radius: 5)
                        }
                    }
                    .id(vm.steps.count)
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
    }
    
    private enum ButtonType {
        case next
        case previous
    }
    
    private func makeButton(of type: ButtonType, screenWidth: CGFloat) -> some View {
        var isAvailable: Bool
        var nextRound: Int
        var text: LocalizedStringResource
        switch type {
        case .next:
            nextRound = vm.round + 1
            text = LocalizedStringResource(stringLiteral: "evaluation_button_next")
            isAvailable = vm.round == vm.steps.count
        case .previous:
            nextRound = vm.round - 1
            text = LocalizedStringResource(stringLiteral: "evaluation_button_previous")
            isAvailable = vm.round == 0
        }
        return Button {
            withAnimation(.easeInOut) {
                vm.round = nextRound
            }
        } label: {
            Text(text)
                .frame(width: max(0, (screenWidth / 2) - 20), height: 50)
                .foregroundStyle(Color.appTextDark)
                .background(Color.appButtonOptionSelected)
                .clipShape(RoundedRectangle(cornerRadius: 15))
//                .shadow(color: Color.green, radius: 5)
        }
        .opacity(isAvailable ? 0.5 : 1)
        .disabled(isAvailable)
    }
}

#Preview {
    FormView()
        .environmentObject(FormViewModel.mock)
}
