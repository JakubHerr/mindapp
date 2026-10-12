//
//  MeditationViewModel.swift
//  MindApp
//
//  Created by Daniel Davidík on 19.05.2024.
//

import AVFoundation
import SwiftUI

class PlayerObserver: NSObject {
    var statusHandler: ((AVPlayerItem.Status) -> Void)?

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let statusNumber = change?[.newKey] as? NSNumber {
                let status = AVPlayerItem.Status(rawValue: statusNumber.intValue) ?? .unknown
                statusHandler?(status)
            }
        }
    }
}

@MainActor
final class MeditationViewModel: ObservableObject {
    @Published var isActive = false
    @Published var timeElapsed = 0
    @Published var scale: CGFloat = 1.0
    @Published var showSessionEvaluation = false

    private var player: AVPlayer?
    private var playerObserver: PlayerObserver?

    func playAudio(from url: URL, volume: Float) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume

        playerObserver = PlayerObserver()
        playerObserver?.statusHandler = { status in
            switch status {
            case .readyToPlay:
                print("AVPlayerItem is ready to play")
            case .failed:
                if let error = playerItem.error {
                    print("AVPlayerItem failed with error: \(error.localizedDescription)")
                }
            case .unknown:
                print("AVPlayerItem status is unknown")
            @unknown default:
                print("AVPlayerItem encountered an unknown status")
            }
        }

        playerItem.addObserver(playerObserver!, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)

        player?.play()
    }

    func stopAudio() {
        player?.pause()
        player = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
