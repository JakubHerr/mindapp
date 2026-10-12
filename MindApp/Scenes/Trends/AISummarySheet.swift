//
//  AISummarySheet.swift
//  MindApp
//
//  Created by Jan Gutwirth on 16.11.2024.
//

import SwiftUI

struct AISummarySheet: View {
    @Binding public var isPresented: Bool
    
    @EnvironmentObject private var vm: AISummaryViewModel
    
    
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                CustomSheetHeaderView(withBackButton: true, action: {
                    isPresented.toggle()
                })
                switch vm.summaryType {
                case .healthSummary:
                    Text("ai_summary_section_header")
                        .font(.appSectionTitle)
                case .healthMotivator:
                    Text("ai_summary_motivator_section_header")
                        .font(.appSectionTitle)
                case .healthSupporter:
                    Text("ai_summary_supporter_section_header")
                        .font(.appSectionTitle)
                default:
                    Text("ai_summary_type_not_supported_header")
                        .font(.appSectionTitle)
                }
                
                icons
                
                ScrollView {
                    ZStack {
                        Text(vm.responseText)
                            .font(.appSenBody)
                            .padding()
                            .background(Color.appBackgroundGreenMain)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .foregroundStyle(Color.appTextBody)
                            .padding()
                            .blur(radius: vm.generating ? 3 : 0)
                        
                        if vm.generating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .background(Color.appCircleBackground)
                                .overlay(Circle().stroke(lineWidth: 2).foregroundStyle(Color.green))
                                .clipShape(RoundedRectangle(cornerRadius: 45))
                        }
                    }
                }
                .scrollIndicators(.hidden)
                Button {
                    Task {
                        vm.voted = false
                        vm.voteResult = nil
                        vm.responseText = ""
                        vm.messageId = ""
                        await vm.handleDifyHealthSummary()
                    }
                } label: {
                    Text("Generate")
                        .padding()
                        .background(Color.appButtonMain)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .disabled(vm.generating || vm.timeRemaining != "Ready!")
                .opacity(vm.generating || vm.timeRemaining != "Ready!" ? 0.5 : 1)
                if !vm.messageId.isEmpty {
                    HStack {
                        Button {
                            Task {
                                await vm.handleSummaryFeedback(feedback: .upvote)
                            }
                            vm.voted = true
                            vm.voteResult = .upvote
                        } label: {
                            Text("👍")
                                .padding()
                                .background(Color.appButtonMain)
                                .clipShape(RoundedRectangle(cornerRadius: 45))
                                .overlay(RoundedRectangle(cornerRadius: 45)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(Color.green)
                                    .opacity(vm.voteResult != nil && vm.voteResult == .upvote ? 1 : 0))
                        }
                        Button {
                            Task {
                                await vm.handleSummaryFeedback(feedback: .downvote)
                            }
                            vm.voted = true
                            vm.voteResult = .downvote
                        } label: {
                            Text("👎")
                                .padding()
                                .background(Color.appButtonMain)
                                .clipShape(RoundedRectangle(cornerRadius: 45))
                                .overlay(RoundedRectangle(cornerRadius: 45)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(Color.green)
                                    .opacity(vm.voteResult != nil && vm.voteResult == .downvote ? 1 : 0))
                        }
                        
                    }
                    .disabled(vm.generating || vm.voted)
                    .opacity(vm.generating || vm.voted ? 0.5 : 1)
                }
                if let lastDate = vm.date {
                    VStack {
                        Text("last_summary_generated_at: \(vm.formatDate(past: lastDate))")
                        Text("next_summary_generation_available_in: \(vm.timeRemaining)")
                            .onReceive(timer) { _ in
                                vm.updateCountdown()
                            }
                    }
                    .padding()
                    .background(Color.appBackgroundItem)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                Spacer()
            }
            if vm.error != nil {
                VStack{
                    ErrorPopup(error: $vm.error)
                    Spacer()
                }                
            }
        }
        .onAppear {
            Task {
                await vm.initialFetch()
            }
        }
        
    }
    
    
    var icons: some View {
        HStack(spacing: 30) {
            if let hd = vm.hdUp {
                VStack {
                    if hd {
                        Image(systemName: "arrow.up.heart")
                    }
                    else {
                        Image(systemName: "arrow.down.heart")
                    }
                    Text("RHR")
                        .font(.appItemSmallTitle)
                }
            }
            if let steps = vm.stepsUp {
                VStack {
                    HStack {
                        Image(systemName: "figure.walk.circle")
                        if steps {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                        }
                        else {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                        }
                    }
                    Text("steps_small_title")
                        .font(.appItemSmallTitle)
                }
            }
            if let cals = vm.calsUp {
                VStack {
                    HStack {
                        Image(systemName: "flame")
                        if cals {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                        }
                        else {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                        }
                    }
                    Text("calories_small_title")
                        .font(.appItemSmallTitle)
                }
            }
        }
    }
    
}

#Preview {
    AISummarySheet(isPresented: .constant(true))
        .environmentObject(AISummaryViewModel.mock)
}
