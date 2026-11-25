//
//  DownloadManagerView.swift
//  QuranMajeed
//

import SwiftUI

struct DownloadManagerView: View {
    @EnvironmentObject var audioService: QuranAudioService
    @EnvironmentObject var dataService: QuranDataService
    @Environment(\.dismiss) var dismiss

    private var downloadedCount: Int {
        dataService.surahs.filter {
            if case .downloaded = audioService.downloadState(for: $0.id) { return true }
            return false
        }.count
    }

    private var allDownloaded: Bool {
        downloadedCount == dataService.surahs.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QuranTheme.pageBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    reciterHeader
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)

                    Rectangle()
                        .fill(QuranTheme.pageBorder.opacity(0.4))
                        .frame(height: 1)

                    List(dataService.surahs) { surah in
                        DownloadSurahRow(surah: surah)
                            .listRowBackground(QuranTheme.pageBackground)
                            .listRowSeparatorTint(QuranTheme.pageBorder.opacity(0.3))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if case .downloaded = audioService.downloadState(for: surah.id) {
                                    Button(role: .destructive) {
                                        audioService.deleteSurah(surah.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Downloads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(QuranTheme.secondaryText)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !allDownloaded {
                        Button("Download All") {
                            audioService.downloadAll()
                        }
                        .foregroundStyle(QuranTheme.goldDark)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private var reciterHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(audioService.selectedReciter?.name ?? "No reciter selected")
                    .font(QuranTheme.arabicFont(size: 17))
                    .foregroundStyle(QuranTheme.arabicText)
                Text(audioService.selectedReciter?.rewaya ?? "")
                    .font(.caption)
                    .foregroundStyle(QuranTheme.secondaryText)
            }
            Spacer()
            Text("\(downloadedCount) / 114 downloaded")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(QuranTheme.secondaryText)
        }
    }
}

struct DownloadSurahRow: View {
    @EnvironmentObject var audioService: QuranAudioService
    let surah: Surah

    private var state: DownloadState {
        audioService.downloadState(for: surah.id)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(surah.id)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(QuranTheme.secondaryText)
                .frame(width: 28, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.englishName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(QuranTheme.arabicText)
                Text(surah.name)
                    .font(QuranTheme.arabicFont(size: 13))
                    .foregroundStyle(QuranTheme.secondaryText)
            }

            Spacer()

            downloadControl
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var downloadControl: some View {
        switch state {
        case .notDownloaded:
            Button { audioService.downloadSurah(surah.id) } label: {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(QuranTheme.secondaryText)
            }
            .buttonStyle(.plain)

        case .downloading(let p):
            Button { audioService.cancelDownload(surah.id) } label: {
                ZStack {
                    CircularProgressView(progress: p)
                        .frame(width: 24, height: 24)
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(QuranTheme.goldDark)
                }
            }
            .buttonStyle(.plain)

        case .downloaded:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(QuranTheme.goldDark)

        case .failed:
            Button { audioService.downloadSurah(surah.id) } label: {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
    }
}
