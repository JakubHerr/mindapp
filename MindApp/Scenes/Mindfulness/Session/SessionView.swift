//
//  SessionView.swift
//  MindApp
//
//  Created by Daniel Davidík on 29.03.2024.
//

import SwiftUI

struct TimeSelection: Equatable, Hashable {
    var minutes: Int
    var seconds: Int
}

let onText = NSLocalizedString("mind_session_on", comment: "On text")
let offText = NSLocalizedString("mind_session_off", comment: "Off text")

struct SessionView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    
    @State private var showInfoView = false

    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            let isGuided = viewModel.activity.name != "unguided-meditation"
            
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                    
                Text(viewModel.activity.localization[0].title)
                    .font(.appSenTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    
                Text(viewModel.activity.localization[0].description)
                    .font(.custom("Sen", size: 14))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
                    
                HStack {
                    if viewModel.activity.category == .meditation {
                        NavigationLink(destination: TimeView().environmentObject(viewModel)) {
                            OptionButtonView(iconName: "timer", titleKey: "mind_session_time", text: viewModel.resolveTimerText(), seconds: viewModel.timeSelection.seconds, isDisabled: isGuided)
                        }
                        .disabled(isGuided)
                    } else {
                        if let cycleCount = viewModel.activity.breathing?.cycleCount {
                            OptionButtonView(iconName: "arrow.clockwise", titleKey: "mind_session_cycles", text: String(cycleCount), isDisabled: true)
                        }
                    }
                        
                    NavigationLink(destination: SoundView().environmentObject(viewModel)) {
                        OptionButtonView(iconName: "speaker.wave.1", titleKey: "mind_session_sound", text: viewModel.resolveSoundText())
                    }
                        
                    if viewModel.activity.category == .meditation {
                        Button(action: {
                            viewModel.isChimeOn.toggle()
                        }) {
                            OptionButtonView(iconName: "alarm", titleKey: "mind_session_chime", text: viewModel.isChimeOn ? onText : offText)
                        }
                    } else {
                        Button(action: {
                            viewModel.isHapticsOn.toggle()
                        }) {
                            OptionButtonView(iconName: "iphone.radiowaves.left.and.right", titleKey: "mind_session_haptics", text: viewModel.isHapticsOn ? onText : offText)
                        }
                    }
                }
                
                if viewModel.activity.category == .meditation && isGuided {
                    HStack {
                        Text("mind_session_by")
                            .font(.custom("Sen", size: 14))
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Link("The Free Mindfulness Project", destination: URL(string: "https://www.freemindfulness.org")!)
                            .font(.custom("Sen", size: 14))
                            .foregroundColor(.green.opacity(0.7))
                    }
                }
                    
                Spacer()
                    
                NavigationLink(destination: CountdownView().environmentObject(viewModel)) {
                    Text("Start")
                        .font(.appSenBody).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appBackgroundGreenMain)
                        .cornerRadius(30)
                }
                .padding()
                .padding(.bottom, 40)
                .ignoresSafeArea()
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.appAccentGreenDark).padding(.bottom, -35))
            }
        }
        .sheet(isPresented: $showInfoView) {
            SessionInfoView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(title: viewModel.activity.category.localized)
            }
                    
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showInfoView = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .dragGesture()
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
            .environmentObject(SessionViewModel.mock())
    }
}
