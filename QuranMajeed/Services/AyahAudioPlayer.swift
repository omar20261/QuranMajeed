//
//  AyahAudioPlayer.swift
//  QuranMajeed
//

import AVFoundation
import Combine
import Foundation

extension Notification.Name {
    static let surahAudioDidStart = Notification.Name("surahAudioDidStart")
    static let ayahAudioDidStart  = Notification.Name("ayahAudioDidStart")
}

class AyahAudioPlayer: ObservableObject {

    @Published var playingVerseKey: String?   // "surahId:ayahNumber"
    @Published var isPlaying    = false
    @Published var isBuffering  = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration:    TimeInterval = 0
    @Published var error: String?

    private var player: AVPlayer?
    private nonisolated(unsafe) var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(surahAudioDidStart),
            name: .surahAudioDidStart,
            object: nil
        )
    }

    deinit {
        stopPlayer()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public

    func playVerse(surahId: Int, ayahNumber: Int, versePath: String) {
        let verseKey = "\(surahId):\(ayahNumber)"

        // Tap on already-playing verse → toggle pause/resume
        if playingVerseKey == verseKey {
            if isPlaying { pause() } else { resume() }
            return
        }

        guard let url = VerseAudioService.shared.verseURL(
            surahId: surahId, ayahNumber: ayahNumber, versePath: versePath
        ) else { return }

        // Tell the surah player to pause before we start
        NotificationCenter.default.post(name: .ayahAudioDidStart, object: nil)

        stopPlayer()
        playingVerseKey = verseKey
        isBuffering     = true
        currentTime     = 0
        duration        = 0
        error           = nil

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.isBuffering = false
                    self.error = nil
                case .failed:
                    self.isBuffering = false
                    self.isPlaying   = false
                    self.playingVerseKey = nil
                    self.error = "Could not load verse audio. Check your connection."
                default: break
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                // Keep player alive so the user can seek or replay; just pause at the end
                self.player?.pause()
                self.isPlaying = false
            }
            .store(in: &cancellables)

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds
            if let d = self.player?.currentItem?.duration, d.isNumeric, d.seconds > 0 {
                self.duration = d.seconds
            }
        }

        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func seek(to fraction: Double) {
        guard duration > 0 else { return }
        let targetSeconds = fraction * duration
        currentTime = targetSeconds   // update UI immediately; don't wait for the periodic observer
        let time = CMTime(seconds: targetSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }

    func stop() {
        stopPlayer()
        isPlaying       = false
        playingVerseKey = nil
        currentTime     = 0
        duration        = 0
    }

    // MARK: - Private

    @objc private func surahAudioDidStart() {
        stop()
    }

    private func stopPlayer() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
