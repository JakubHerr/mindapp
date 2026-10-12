//
//  MeditationView.swift
//  MindApp
//
//  Created by Daniel Davidík on 07.04.2024.
//

import SwiftUI

struct MeditationView: View {
    @EnvironmentObject var router: NavPathRouter
    @EnvironmentObject var sessionViewModel: SessionViewModel

    @StateObject var soundViewModel = SoundViewModel()
    @StateObject var viewModel = MeditationViewModel()

    @Environment(\.presentationMode) var presentationMode

    var timeToRun: Int {
        if sessionViewModel.timeSelection.minutes == 0 && sessionViewModel.timeSelection.seconds == 0 { return 36000 }

        return sessionViewModel.timeSelection.minutes * 60 + sessionViewModel.timeSelection.seconds + 3 // some cushion seconds in case the audio starts playing later
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                Text("mind_session_time")
                    .font(.appSenTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                ZStack {
                    Circle()
                        .fill(Color.appCircleBackground)
                        .frame(width: 195, height: 195)

                    Circle()
                        .stroke(lineWidth: 5.0)
                        .opacity(0.3)
                        .foregroundColor(Color.appBackgroundGreenMain)

                    Text(String(format: "%02d:%02d", viewModel.timeElapsed / 60, viewModel.timeElapsed % 60))
                        .font(.custom("Sen", size: 30))
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(width: 200, height: 200)
                .padding(40)
                .onReceive(timer) { _ in
                    if viewModel.isActive && viewModel.timeElapsed < self.timeToRun {
                        viewModel.timeElapsed += 1
                    } else {
                        self.timer.upstream.connect().cancel()
                        soundViewModel.stopAllSounds()
                        router.navigateTo(.sessionEvaluationView)
                    }
                }

                Spacer()

                Button(action: {
                    viewModel.isActive = false
                    router.navigateTo(.sessionEvaluationView)
                }) {
                    Text("mind_session_end")
                        .font(.appSenBody).bold()
                        .foregroundColor(.appTextBody)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appBackgroundGreenMain)
                        .cornerRadius(30)
                }
                .padding()
            }
        }
        .onAppear {
            if let downloadUrlString = sessionViewModel.activity.meditation?.downloadUrl, let url = URL(string: downloadUrlString) {
                viewModel.playAudio(from: url, volume: Float(1.0))
            } else {
                print("No download URL found for meditation sound.")
            }

            if sessionViewModel.selectedSound != .none {
                soundViewModel.playSound(named: sessionViewModel.selectedSound.rawValue, volume: sessionViewModel.volume)
            }

            viewModel.isActive = true
            self.sessionViewModel.startSession()

            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            self.sessionViewModel.endSession()
            viewModel.isActive = false

            self.timer.upstream.connect().cancel()
            soundViewModel.stopAllSounds()
            viewModel.stopAudio()

            UIApplication.shared.isIdleTimerDisabled = false
        }
        .navigationBarBackButtonHidden(true)
        .dragGesture()
    }
}

struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {
        MeditationView()
            .environmentObject(NavPathRouter.mock())
            .environmentObject(SessionViewModel.mock())
    }
}
