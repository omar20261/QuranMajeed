//
//  ControlToolbar.swift
//  QuranMajeed
//

import SwiftUI

struct ControlToolbar: View {
    let currentPage: Int
    let totalPages: Int
    let juz: Int
    let isBookmarked: Bool
    let isAudioPlaying: Bool
    let onSurahListTap: () -> Void
    let onBookmarkTap: () -> Void
    let onAudioTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(QuranTheme.pageBorder)
                .frame(height: 1)

            HStack(alignment: .center) {
                // Left: list + audio
                HStack(spacing: 0) {
                    Button(action: onSurahListTap) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(QuranTheme.goldDark)
                            .frame(width: 44)
                    }

                    Button(action: onAudioTap) {
                        Image(systemName: isAudioPlaying ? "headphones.circle.fill" : "headphones")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(isAudioPlaying ? QuranTheme.gold : QuranTheme.goldDark)
                            .frame(width: 44)
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Page \(currentPage) • صفحة \(currentPage.arabicNumeral)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(QuranTheme.arabicText)
                    Text("Juz \(juz) • الجزء \(juz.arabicNumeral)")
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                }

                Spacer()

                Button(action: onBookmarkTap) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(QuranTheme.goldDark)
                        .frame(width: 44)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .background(QuranTheme.pageBackground)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        Spacer()
        ControlToolbar(
            currentPage: 1,
            totalPages: 604,
            juz: 1,
            isBookmarked: false,
            isAudioPlaying: false,
            onSurahListTap: {},
            onBookmarkTap: {},
            onAudioTap: {}
        )
    }
    .background(QuranTheme.pageBackground)
}
