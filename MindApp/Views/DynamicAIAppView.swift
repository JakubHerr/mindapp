//
//  DynamicAIAppView.swift
//  MindApp
//
//  Created by Jan Gutwirth on 07.03.2025.
//

import SwiftUI

struct DynamicAIAppView: View {
    
    @EnvironmentObject var vm: DynamicAIAppViewModel
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            VStack (spacing: 20) {
                
                ScrollViewReader { proxy in
                    ScrollView {
                        Text(vm.title)
                            .font(.appSenTitle)
                            .multilineTextAlignment(.center)
                        
                        Text(vm.description)
                            .font(.appSenBody)
                            .multilineTextAlignment(.center)
                        HStack {
                            Text("URL:")
                            Text(vm.url)
                        }
                        .font(.appSenBody)
                        HStack {
                            Text("Key:")
                            Text(maskedKey(vm.key))
                        }
                        .font(.appSenBody)
                        
                        ForEach(vm.parameterOptions.indices, id: \.self) { index in
                            HStack {
                                Text(vm.parameterOptions[index].parameter.name.rawValue)
                                    .font(.appSenBody)
                                if vm.parameterOptions[index].parameter.requirement == .optional {
                                    Toggle("", isOn: $vm.parameterOptions[index].value)
                                }
                                else {
                                    Toggle("", isOn: .constant(true))
                                        .disabled(true)
                                }
                            }
                            .padding(.horizontal)
                        }
                        HStack {
                            Text("response_mode_toggle")
                                .font(.appSenBody)
                            Toggle(vm.responseModeToggle ? "streaming" : "blocking", isOn: $vm.responseModeToggle)
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            Text("input_section")
                                .font(.appSenBody)
                            TextField("", text: $vm.input)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(Color.green)
                                )
                        }
                        .padding()
                        .background(Color.appBackgroundGreenMain)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                        VStack {
                            Text("output_section")
                                .font(.appSenBody)
                            ZStack {
                                Text(vm.output)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color.green)
                                    )
                                if vm.generating {
                                    ProgressView()
                                }
                            }
                        }
                        .id("output")
                        .padding()
                        .background(Color.appBackgroundGreenMain)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                    }
                    .onChange(of: vm.output) { _ in
                        withAnimation {
                            proxy.scrollTo("output")
                        }
                    }
                }
                Button {
                    self.vm.output = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    Task {
                        await vm.runAIApp()
                    }
                } label: {
                    Text("send_request_button")
                        .padding()
                        .font(.appSenBody)
                        .foregroundStyle(Color.appTextBody)
                        .background(Color.appBackgroundGreenMain)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: .green, radius: 5)
                        .padding()
                }
                .disabled(vm.generating || vm.input.isEmpty)
                .opacity(vm.generating || vm.input.isEmpty ? 0.5 : 1)
            }
            .foregroundStyle(Color.appTextBody)
            if vm.error != nil {
                VStack {
                    ErrorPopup(error: $vm.error)
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "AI App")
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func maskedKey(_ key: String) -> String {
        let visibleCount = min(10, key.count)
        let visiblePart = key.prefix(visibleCount)
        let maskedPart = String(repeating: "*", count: key.count - visibleCount)
        return visiblePart + maskedPart
    }
}

#Preview {
    DynamicAIAppView()
        .environmentObject(DynamicAIAppViewModel.mock)
}
