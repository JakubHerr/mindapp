//
//  ReflectionSessionView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 05.03.2025.
//

import SwiftUI

struct ReflectionSessionView: View {

    @StateObject var vm: ReflectionSessionViewModel = ReflectionSessionViewModel()

    @Environment(\.dismiss) var dismiss

    @State var prompt: String = ""

    @StateObject var router: NavPathRouter = .init()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                Color.appSessionBackground.edgesIgnoringSafeArea(.all)

                VStack {
                    
                    messages
                    
                    Spacer()
                    
                    if vm.generating {
                        Text("generating_status_text")
                            .animation(.easeInOut)
                    }
                    
                    if !vm.conversationFinished {
                        chatInputBar
                    }
                    else {
                        NavigationLink(value: NavigationDestination.reflectionEvaluation) {
                            Text("reflection_button_continue_to_evaluation")
                                .padding()
                                .foregroundStyle(Color.appTextBody)
                                .background(Color.appButtonMain)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                }
                .padding()
                
                if vm.error != nil {
                    VStack {
                        ErrorPopup(error: $vm.error)
                        Spacer()
                    }
                }
            }
            .onAppear {
                if vm.conversationFinished {
                    self.dismiss()
                }
                else {
                    Task {
                        await vm.startSession()
                    }
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                if case .reflectionEvaluation = destination {
                    FormView().toolbar(.hidden)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "chat_with_ai", requiresConfirmation: true)
                    .foregroundStyle(Color.white)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(router.path.isEmpty ? .visible : .hidden, for: .navigationBar)
        .environmentObject(vm.fvm)
        .environmentObject(router)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline) //if not present, the toolbar appears to have a chunky chin
    }
    
    var chatInputBar: some View {
        HStack {
            TextField("", text: $prompt, prompt: Text("reflection_prompt").foregroundColor(.appAccentBright))
                .keyboardType(.default)
                .padding()
                .background(Color.appBackgroundGreenMain)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .disabled(vm.chat.isEmpty || vm.generating)
            Button {
                if !vm.isCurrQuestionnaireOpen {
                    if let questionaire = vm.chat[vm.currQuestionaireIndex] as? Questionnaire {
                        vm.selectedQuestion = questionaire.getSelectedQuestion().text
                    }
                    vm.lockLatestQuestionaire()
                    vm.generateNextResponse(input: prompt)
                    vm.chat.append(TextMessage(text: prompt, isRequest: true))
                    prompt = ""
                }
                else {
                    vm.error = DifyError.invalidData //shouldn't be even reachable
                }
            } label: {
                withAnimation {
                    Image(systemName: "paperplane")
                        .font(.system(size: 30))
                        .bold()
                        .foregroundColor(prompt.isEmpty || vm.chat.isEmpty || vm.isCurrQuestionnaireOpen ? .gray : .white)
                }
            }
            .disabled(prompt.isEmpty || vm.chat.isEmpty || vm.generating || vm.isCurrQuestionnaireOpen)
            
        }
    }
    
    var messages: some View {
        ScrollViewReader { proxy in
            ScrollView{
                ForEach(vm.chat, id: \.id) { message in
                    MessageView(message: message)
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: vm.chat) { _ in
                withAnimation {
                    if let lastMessage = vm.chat.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

#Preview {
    ReflectionSessionView()
}
