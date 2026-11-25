//
//  QuranAudioService.swift
//  QuranMajeed
//

import AVFoundation
import Combine
import Foundation
import MediaPlayer

enum DownloadState: Equatable {
    case notDownloaded
    case downloading(Double)
    case downloaded
    case failed

    static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
        switch (lhs, rhs) {
        case (.notDownloaded, .notDownloaded): return true
        case (.downloading, .downloading): return true
        case (.downloaded, .downloaded): return true
        case (.failed, .failed): return true
        default: return false
        }
    }
}

class QuranAudioService: ObservableObject {

    // MARK: - Reciters
    @Published var reciters: [Reciter] = []
    @Published var selectedReciter: Reciter? {
        didSet {
            saveSelectedReciter()
            if let reciter = selectedReciter {
                initializeDownloadStates(for: reciter)
            }
            if isPlaying, let surahId = currentSurahId {
                play(surahId: surahId)
            }
        }
    }
    @Published var isLoadingReciters = false

    // MARK: - Playback
    @Published var currentSurahId: Int?
    @Published var isPlaying = false
    @Published var isPlayerVisible = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isBuffering = false

    // MARK: - Verse Playback
    @Published var playingVerseKey: String?  // "surahId:ayahNumber" while a verse is playing

    // MARK: - Downloads
    @Published var downloadStates: [String: DownloadState] = [:]

    // MARK: - Private
    private var player: AVPlayer?
    private nonisolated(unsafe) var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()
    private var surahs: [Surah] = []
    private var downloadTasks: [String: URLSessionDownloadTask] = [:]
    private var downloadObservations: [String: NSKeyValueObservation] = [:]

    init() {
        setupAudioSession()
        reciters = Reciter.all
        loadSelectedReciter()
        if selectedReciter == nil {
            selectedReciter = Reciter.defaultReciter
        }
        setupRemoteControls()
    }

    func configure(surahs: [Surah]) {
        self.surahs = surahs
        if let reciter = selectedReciter {
            initializeDownloadStates(for: reciter)
        }
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        Task.detached(priority: .userInitiated) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session error: \(error)")
            }
        }
    }

    // MARK: - Reciters

    func fetchReciters() async {
        // Reciters are hardcoded — no network call needed
        reciters = Reciter.all
        if selectedReciter == nil || !reciters.contains(where: { $0.id == selectedReciter?.id }) {
            selectedReciter = Reciter.defaultReciter
        }
    }

    // MARK: - Playback

    func prepare(surahId: Int) {
        currentSurahId = surahId
        isPlayerVisible = true
        playingVerseKey = nil
    }

    func play(surahId: Int) {
        guard let reciter = selectedReciter else { return }

        currentSurahId = surahId
        isPlayerVisible = true
        isBuffering = true
        currentTime = 0
        duration = 0
        playingVerseKey = nil

        let audioURL: URL
        if let local = localFileURL(surahId: surahId, reciterId: reciter.id),
           FileManager.default.fileExists(atPath: local.path)
        {
            audioURL = local
        } else {
            guard let remote = reciter.surahURL(for: surahId) else { return }
            audioURL = remote
        }

        stopCurrentPlayer()

        let item = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: item)

        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay: self.isBuffering = false
                case .failed:
                    self.isBuffering = false
                    self.isPlaying = false
                default: break
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.isPlaying = false
                self.nextSurah()
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
            self.updateNowPlayingInfo()
        }

        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func resume() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else if player != nil {
            resume()
        } else if let surahId = currentSurahId {
            play(surahId: surahId)
        }
    }

    func seek(to fraction: Double) {
        guard duration > 0 else { return }
        let time = CMTime(seconds: fraction * duration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }

    func nextSurah() {
        guard playingVerseKey == nil else { return }
        guard let current = currentSurahId, current < 114 else { return }
        play(surahId: current + 1)
    }

    func previousSurah() {
        guard let current = currentSurahId else { return }
        if currentTime > 3 {
            seek(to: 0)
        } else if current > 1 {
            play(surahId: current - 1)
        }
    }

    func playVerse(surahId: Int, ayahNumber: Int) {
        let verseKey = "\(surahId):\(ayahNumber)"
        if playingVerseKey == verseKey {
            togglePlayPause()
            return
        }

        guard let reciter = selectedReciter,
              let url = VerseAudioService.shared.verseURL(surahId: surahId, ayahNumber: ayahNumber, versePath: reciter.versePath)
        else { return }

        stopCurrentPlayer()
        playingVerseKey = verseKey
        currentSurahId = surahId
        isPlayerVisible = true
        isBuffering = true
        currentTime = 0
        duration = 0

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay: self.isBuffering = false
                case .failed:
                    self.isBuffering = false
                    self.isPlaying = false
                    self.playingVerseKey = nil
                default: break
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                if let token = self.timeObserverToken {
                    self.player?.removeTimeObserver(token)
                    self.timeObserverToken = nil
                }
                self.player = nil
                self.isPlaying = false
                self.playingVerseKey = nil
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

    private func stopCurrentPlayer() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    // MARK: - Lock Screen / Remote Controls

    private func updateNowPlayingInfo() {
        let surah = surahs.first { $0.id == currentSurahId }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: surah?.englishName ?? "Surah \(currentSurahId ?? 0)",
            MPMediaItemPropertyArtist: selectedReciter?.name ?? "",
            MPMediaItemPropertyAlbumTitle: "القرآن الكريم",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func setupRemoteControls() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.resume() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.pause() }
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.togglePlayPause() }
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.nextSurah() }
            return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.previousSurah() }
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let e = event as? MPChangePlaybackPositionCommandEvent {
                Task { @MainActor [weak self] in
                    guard let self, self.duration > 0 else { return }
                    self.seek(to: e.positionTime / self.duration)
                }
            }
            return .success
        }
    }

    // MARK: - Downloads

    func downloadState(for surahId: Int) -> DownloadState {
        guard let reciter = selectedReciter else { return .notDownloaded }
        return downloadStates[downloadKey(surahId: surahId, reciterId: reciter.id)] ?? .notDownloaded
    }

    func downloadSurah(_ surahId: Int) {
        guard let reciter = selectedReciter,
              let remoteURL = reciter.surahURL(for: surahId) else { return }

        let key = downloadKey(surahId: surahId, reciterId: reciter.id)

        // Skip if already downloaded or in progress
        switch downloadStates[key] ?? .notDownloaded {
        case .downloaded, .downloading: return
        default: break
        }

        downloadStates[key] = .downloading(0)

        let task = URLSession.shared.downloadTask(with: remoteURL) { [weak self] tempURL, _, error in
            Task { @MainActor [weak self] in
                guard let self else { return }

                self.downloadObservations[key]?.invalidate()
                self.downloadObservations[key] = nil
                self.downloadTasks[key] = nil

                if let urlError = error as? URLError, urlError.code == .cancelled {
                    self.downloadStates[key] = .notDownloaded
                    return
                }

                guard error == nil,
                      let tempURL,
                      let destURL = self.localFileURL(surahId: surahId, reciterId: reciter.id)
                else {
                    self.downloadStates[key] = .failed
                    return
                }

                do {
                    let dir = destURL.deletingLastPathComponent()
                    if !FileManager.default.fileExists(atPath: dir.path) {
                        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                    }
                    if FileManager.default.fileExists(atPath: destURL.path) {
                        try FileManager.default.removeItem(at: destURL)
                    }
                    try FileManager.default.moveItem(at: tempURL, to: destURL)
                    self.downloadStates[key] = .downloaded
                } catch {
                    self.downloadStates[key] = .failed
                }
            }
        }

        downloadObservations[key] = task.progress.observe(\.fractionCompleted, options: [.new]) { [weak self] _, change in
            let progress = change.newValue ?? 0
            Task { @MainActor [weak self] in
                self?.downloadStates[key] = .downloading(progress)
            }
        }

        downloadTasks[key] = task
        task.resume()
    }

    func cancelDownload(_ surahId: Int) {
        guard let reciter = selectedReciter else { return }
        let key = downloadKey(surahId: surahId, reciterId: reciter.id)
        downloadObservations[key]?.invalidate()
        downloadObservations[key] = nil
        downloadTasks[key]?.cancel()
        downloadTasks[key] = nil
        downloadStates[key] = .notDownloaded
    }

    func deleteSurah(_ surahId: Int) {
        guard let reciter = selectedReciter,
              let url = localFileURL(surahId: surahId, reciterId: reciter.id)
        else { return }
        try? FileManager.default.removeItem(at: url)
        downloadStates[downloadKey(surahId: surahId, reciterId: reciter.id)] = .notDownloaded
    }

    func downloadAll() {
        for surahId in 1...114 {
            switch downloadState(for: surahId) {
            case .notDownloaded, .failed:
                downloadSurah(surahId)
            default:
                break
            }
        }
    }

    func localFileURL(surahId: Int, reciterId: Int) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("audio/\(reciterId)/\(String(format: "%03d", surahId)).mp3")
    }

    private func initializeDownloadStates(for reciter: Reciter) {
        for surahId in 1...114 {
            let key = downloadKey(surahId: surahId, reciterId: reciter.id)
            guard downloadStates[key] == nil else { continue }
            downloadStates[key] = isFileDownloaded(surahId: surahId, reciterId: reciter.id)
                ? .downloaded
                : .notDownloaded
        }
    }

    private func isFileDownloaded(surahId: Int, reciterId: Int) -> Bool {
        guard let url = localFileURL(surahId: surahId, reciterId: reciterId) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    private func downloadKey(surahId: Int, reciterId: Int) -> String {
        "\(reciterId)_\(surahId)"
    }

    // MARK: - Persistence

    private func saveSelectedReciter() {
        guard let reciter = selectedReciter,
              let data = try? JSONEncoder().encode(reciter)
        else { return }
        UserDefaults.standard.set(data, forKey: "selectedReciter")
    }

    private func loadSelectedReciter() {
        guard let data = UserDefaults.standard.data(forKey: "selectedReciter"),
              let reciter = try? JSONDecoder().decode(Reciter.self, from: data)
        else { return }
        selectedReciter = reciter
    }
}
