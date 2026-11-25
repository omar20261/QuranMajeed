//
//  AudioMiniPlayerView.swift
//  QuranMajeed
//

import SwiftUI

struct AudioMiniPlayerView: View {
    @EnvironmentObject var audioService: QuranAudioService
    @EnvironmentObject var dataService: QuranDataService
    let onTap: () -> Void

    private var surah: Surah? {
        dataService.surahs.first { $0.id == audioService.currentSurahId }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(QuranTheme.pageBorder)
                .frame(height: 1)

            HStack(spacing: 12) {
                    // Surah info — tap to open full player
                    Button(action: onTap) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(surah?.name ?? "")
                                .font(QuranTheme.arabicFont(size: 15))
                                .foregroundStyle(QuranTheme.arabicText)
                                .lineLimit(1)
                            Text(audioService.selectedReciter?.name ?? "")
                                .font(.caption)
                                .foregroundStyle(QuranTheme.secondaryText)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    // Controls
                    HStack(spacing: 2) {
                        Button { audioService.previousSurah() } label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(QuranTheme.goldDark)
                                .frame(width: 34, height: 40)
                        }

                        Button { audioService.togglePlayPause() } label: {
                            Group {
                                if audioService.isBuffering {
                                    ProgressView()
                                        .tint(QuranTheme.goldDark)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(QuranTheme.goldDark)
                                }
                            }
                            .frame(width: 40, height: 40)
                        }

                        Button { audioService.nextSurah() } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(QuranTheme.goldDark)
                                .frame(width: 34, height: 40)
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(QuranTheme.pageBackground)
    }


}
