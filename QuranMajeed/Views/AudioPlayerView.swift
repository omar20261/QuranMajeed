//
//  AudioPlayerView.swift
//  QuranMajeed
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var audioService: QuranAudioService
    @EnvironmentObject var dataService: QuranDataService
    @Environment(\.dismiss) var dismiss

    @State private var showReciterSelect = false
    @State private var showDownloads = false
    @State private var isSeeking = false
    @State private var seekValue: Double = 0

    private var surah: Surah? {
        dataService.surahs.first { $0.id == audioService.currentSurahId }
    }

    private var sliderValue: Double {
        isSeeking ? seekValue : (audioService.duration > 0 ? audioService.currentTime / audioService.duration : 0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QuranTheme.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        surahHeader
                        progressSection
                        controlsSection
                        bottomActions
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(QuranTheme.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(QuranTheme.current.toolbarColorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(QuranTheme.secondaryText)
                    }
                }
            }
        }
        .sheet(isPresented: $showReciterSelect) {
            ReciterSelectView()
        }
        .sheet(isPresented: $showDownloads) {
            DownloadManagerView()
        }
    }

    // MARK: - Surah Header

    private var surahHeader: some View {
        VStack(spacing: 10) {
            // Decorative ornament
            Image(systemName: "sparkle")
                .font(.system(size: 14))
                .foregroundStyle(QuranTheme.gold)

            Text(surah?.name ?? "")
                .font(QuranTheme.arabicFont(size: 42))
                .foregroundStyle(QuranTheme.arabicText)
                .multilineTextAlignment(.center)

            Text(surah?.englishName ?? "")
                .font(.title2.weight(.semibold))
                .foregroundStyle(QuranTheme.arabicText)

            Text(surah?.englishTranslation ?? "")
                .font(.subheadline)
                .foregroundStyle(QuranTheme.secondaryText)

            // Reciter chip
            Button {
                showReciterSelect = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "music.microphone")
                        .font(.caption)
                    Text(audioService.selectedReciter?.name ?? "Select Reciter")
                        .font(.subheadline)
                        .lineLimit(1)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .foregroundStyle(QuranTheme.goldDark)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(QuranTheme.goldLight.opacity(0.3))
                        .overlay(Capsule().stroke(QuranTheme.pageBorder.opacity(0.5), lineWidth: 1))
                )
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 8) {
            if let error = audioService.audioError {
                HStack(spacing: 6) {
                    Image(systemName: "wifi.slash")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.red.opacity(0.8))
                .padding(.bottom, 4)
            }
            Slider(
                value: Binding(
                    get: { sliderValue },
                    set: { seekValue = $0 }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    isSeeking = editing
                    if !editing {
                        audioService.seek(to: seekValue)
                    }
                }
            )
            .tint(QuranTheme.goldDark)

            HStack {
                Text(formatTime(audioService.currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(QuranTheme.secondaryText)
                Spacer()
                Text(formatTime(audioService.duration))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(QuranTheme.secondaryText)
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 36) {
            Button { audioService.previousSurah() } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(QuranTheme.goldDark)
            }

            Button { audioService.togglePlayPause() } label: {
                ZStack {
                    Circle()
                        .fill(QuranTheme.goldDark)
                        .frame(width: 76, height: 76)
                        .shadow(color: QuranTheme.goldDark.opacity(0.4), radius: 8, y: 4)

                    if audioService.isBuffering {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.3)
                    } else {
                        Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                            .offset(x: audioService.isPlaying ? 0 : 2)
                    }
                }
            }

            Button { audioService.nextSurah() } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(QuranTheme.goldDark)
            }
        }
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        HStack(spacing: 12) {
            downloadButton
            Spacer()
            downloadsManagerButton
        }
    }

    private var downloadButton: some View {
        let surahId = audioService.currentSurahId ?? 0
        let state = audioService.downloadState(for: surahId)

        return Button {
            switch state {
            case .notDownloaded, .failed:
                audioService.downloadSurah(surahId)
            case .downloaded:
                audioService.deleteSurah(surahId)
            case .downloading:
                audioService.cancelDownload(surahId)
            }
        } label: {
            HStack(spacing: 6) {
                downloadStateIcon(state)
                Text(downloadStateLabel(state))
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(state == .downloaded ? QuranTheme.goldDark : QuranTheme.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(QuranTheme.goldLight.opacity(0.25))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(QuranTheme.pageBorder.opacity(0.4), lineWidth: 1))
            )
        }
    }

    private var downloadsManagerButton: some View {
        Button {
            showDownloads = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 14))
                Text("Manage Downloads")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(QuranTheme.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(QuranTheme.goldLight.opacity(0.25))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(QuranTheme.pageBorder.opacity(0.4), lineWidth: 1))
            )
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func downloadStateIcon(_ state: DownloadState) -> some View {
        switch state {
        case .notDownloaded:
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 14))
        case .downloading(let p):
            CircularProgressView(progress: p)
                .frame(width: 14, height: 14)
        case .downloaded:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
        case .failed:
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 14))
        }
    }

    private func downloadStateLabel(_ state: DownloadState) -> String {
        switch state {
        case .notDownloaded: "Download Surah"
        case .downloading(let p): "Downloading \(Int(p * 100))%"
        case .downloaded: "Downloaded"
        case .failed: "Retry Download"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, !seconds.isNaN, seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Circular Progress

struct CircularProgressView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(QuranTheme.goldLight, lineWidth: 2)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(QuranTheme.goldDark, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
