//
//  BreathingView.swift
//  MindApp
//
//  Created by Daniel Davidík on 19.04.2024.
//

import CoreHaptics
import SwiftUI

enum BreathingPhase {
    case inhale, hold, exhale
}

struct BreathingView: View {
    @EnvironmentObject var router: NavPathRouter
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @EnvironmentObject var viewModel: BreathingViewModel

    @Environment(\.presentationMode) var presentationMode

    @StateObject var soundViewModel = SoundViewModel()

    @State private var scale: CGFloat = 1.0
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var engine: CHHapticEngine?
    @State private var hapticPlayer: CHHapticPatternPlayer?

    var body: some View {
        ZStack {
            Color.appSessionBackground.edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.appBackgroundGreenMain)
                        .scaleEffect(self.scale)
                        .frame(width: 200, height: 200)
                        .onAppear {
                            startBreathingCycle()
                        }

                    self.displayPhaseText
                }
                .frame(width: 200, height: 200)
                .padding(40)

                Spacer()

                Button(action: {
                    self.router.navigateTo(.sessionEvaluationView)
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
            if self.sessionViewModel.selectedSound != .none {
                self.soundViewModel.playSound(named: self.sessionViewModel.selectedSound.rawValue, volume: self.sessionViewModel.volume)
            }

            prepareHaptics()
            self.sessionViewModel.startSession()

            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            self.sessionViewModel.endSession()
            self.soundViewModel.stopAllSounds()
            stopHaptic()

            UIApplication.shared.isIdleTimerDisabled = false
        }
        .navigationBarBackButtonHidden(true)
        .dragGesture()
    }

    @ViewBuilder
    var displayPhaseText: some View {
        if currentPhase == .inhale {
            Text("mind_session_inhale")
                .font(.custom("Sen", size: 26))
                .scaleEffect(1)
                .bold()
                .foregroundColor(.white)
        }

        if currentPhase == .hold {
            Text("mind_session_hold")
                .font(.custom("Sen", size: 26))
                .scaleEffect(1)
                .bold()
                .foregroundColor(.white)
        }

        if currentPhase == .exhale {
            Text("mind_session_exhale")
                .font(.custom("Sen", size: 26))
                .scaleEffect(1)
                .bold()
                .foregroundColor(.white)
        }
    }

    func startBreathingCycle() {
        currentPhase = .inhale
        withAnimation(Animation.easeInOut(duration: viewModel.inhaleDuration)) {
            scale = 1.5
        }
        playHaptic(for: .inhale)

        DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.inhaleDuration) {
            self.currentPhase = .hold
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.inhaleDuration + viewModel.holdDuration) {
            self.currentPhase = .exhale
            withAnimation(Animation.easeInOut(duration: viewModel.exhaleDuration)) {
                scale = 1.0
            }
            playHaptic(for: .exhale)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.inhaleDuration + viewModel.holdDuration + viewModel.exhaleDuration) {
            self.currentPhase = .hold
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.inhaleDuration + viewModel.holdDuration + viewModel.exhaleDuration + viewModel.secondHoldDuration) {
            viewModel.currentCycleCount += 1

            if viewModel.currentCycleCount == viewModel.cycleCount {
                self.router.navigateTo(.sessionEvaluationView)
                return
            }

            startBreathingCycle()
        }
    }

    func playHaptic(for phase: BreathingPhase) {
        if sessionViewModel.isHapticsOn == false { return }

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            let intensity: CHHapticEventParameter
            let sharpness: CHHapticEventParameter
            let duration: Float

            switch phase {
            case .inhale:
                intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
                sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                duration = Float(viewModel.inhaleDuration)
            case .exhale:
                intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
                sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                duration = Float(viewModel.exhaleDuration)
            case .hold: return
            }

            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: TimeInterval(duration))
            let pattern = try CHHapticPattern(events: [event], parameters: [])

            hapticPlayer = try engine?.makePlayer(with: pattern)
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            Logger.log("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }

    func stopHaptic() {
        if hapticPlayer == nil { return }

        do {
            try hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
            hapticPlayer = nil
        } catch {
            Logger.log("Failed to stop haptic pattern: \(error.localizedDescription)")
        }

        engine?.stop()
    }

    func prepareHaptics() {
        if sessionViewModel.isHapticsOn == false { return }

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            Logger.log("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
}

struct BreathingView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingView()
            .environmentObject(NavPathRouter.mock())
            .environmentObject(SessionViewModel.mock())
            .environmentObject(BreathingViewModel.mock()) //might need better example for mocking -> might need multiple different mocks for different usages
    }
}
