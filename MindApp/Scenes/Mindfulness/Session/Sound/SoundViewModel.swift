//
//  SoundViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 07.04.2024.
//

import AVFoundation
import SwiftUI

class SoundViewModel: ObservableObject {
    private var players: [AVAudioPlayer] = []

    func playSound(named soundName: String, volume: Double, numberOfLoops: Int = -1) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            Logger.log("Could not find URL with name: \(soundName)")
            return
        }

        playSoundFromUrl(from: url, volume: volume, numberOfLoops: numberOfLoops)
    }

    func playSoundFromUrl(from url: URL, volume: Double, numberOfLoops: Int) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Logger.log("Failed to set audio session category: \(error.localizedDescription)")
            return
        }

        do {
            Logger.log("Playing sound from URL: \(url)")

            do {
                _ = try url.checkResourceIsReachable()
            } catch let e {
                Logger.log("URL is not reachable: \(e.localizedDescription)")
            }

            let player = try AVAudioPlayer(contentsOf: url)

            player.volume = Float(volume)
            player.numberOfLoops = numberOfLoops
            player.prepareToPlay()
            player.play()

            players.append(player)
        } catch {
            Logger.log("Error playing sound: \(error)")
        }
    }

    func stopAllSounds() {
        for player in players {
            player.stop()
        }

        players.removeAll()

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            Logger.log("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    func changeVolumeOfFirst(volume: Double) {
        players.first?.volume = Float(volume)
    }
}
