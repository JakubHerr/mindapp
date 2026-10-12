//
//  SoundView.swift
//  MindApp
//
//  Created by Daniel Davidík on 29.03.2024.
//

import AVFoundation
import SwiftUI

enum Sound: String, CaseIterable, Hashable, Equatable {
    case none = "None"
    case bird = "Bird Whistling"
    case rainfall = "Rainfall"
    case harmonic = "Harmonic"
}

struct SoundIcon {
    let sound: Sound
    let iconName: String
}

struct SoundView: View {
    @StateObject var viewModel = SoundViewModel()

    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    let sounds: [SoundIcon] = [
        SoundIcon(sound: .none, iconName: "speaker.slash"),
        SoundIcon(sound: .bird, iconName: "bird"),
        SoundIcon(sound: .rainfall, iconName: "cloud.rain"),
        SoundIcon(sound: .harmonic, iconName: "circle.hexagonpath"),
    ]

    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            VStack(spacing: 0) {
                Text("mind_session_sound")
                    .font(.appSenTitle).bold()
                    .foregroundStyle(Color.white)
                    .padding(.bottom, 32)
                
                HStack {
                    Image(systemName: "speaker")
                        .foregroundStyle(Color.white)
                        .padding()
                    
                    Slider(value: $sessionViewModel.volume, in: 0 ... 1, onEditingChanged: { _ in
                        viewModel.changeVolumeOfFirst(volume: sessionViewModel.volume)
                    })
                    .accentColor(Color.white)
                    
                    Image(systemName: "speaker.wave.2")
                        .foregroundStyle(Color.white)
                        .padding()
                }
                .background(Color.appButtonOption)
                .cornerRadius(10)
                .padding(.horizontal)
                
                List {
                    ForEach(sounds, id: \.sound) { soundType in
                        let isSelected = sessionViewModel.selectedSound == soundType.sound
                        
                        HStack {
                            Image(systemName: soundType.iconName)
                            
                            Text(sessionViewModel.resolveSoundText(sound: soundType.sound))
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                            } else {
                                Image(systemName: "speaker.wave.2")
                                    .foregroundStyle(Color.appAccentBright)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            sessionViewModel.selectedSound = soundType.sound
                            
                            viewModel.stopAllSounds()
                                
                            if sessionViewModel.selectedSound == .none {
                                return
                            }
                                
                            viewModel.playSound(named: sessionViewModel.selectedSound.rawValue, volume: sessionViewModel.volume)
                        }
                        .listRowBackground(isSelected ? Color.appButtonOptionSelected : Color.appButtonOption)
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 300)
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.appAccentBright)
                .cornerRadius(15)
                
                Text("mind_sounds_desc")
                    .font(.appSenBody)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top)
            }
            .padding(.horizontal)
        }
        .onAppear {
            if sessionViewModel.selectedSound != .none {
                viewModel.playSound(named: sessionViewModel.selectedSound.rawValue, volume: sessionViewModel.volume)
            }
        }
        .onDisappear {
            viewModel.stopAllSounds()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(title: "back")
            }
        }
        .dragGesture()
    }
}

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView()
            .environmentObject(SessionViewModel.mock())
    }
}
