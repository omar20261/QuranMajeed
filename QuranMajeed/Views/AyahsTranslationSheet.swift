//
//  AyahsTranslationSheet.swift
//  QuranMajeed
//

import SwiftUI

struct AyahsTranslationSheet: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let surahId: Int
    let ayahs: [Ayah]
    let totalSurahAyahs: Int
    let surahEnglishName: String
    let surahArabicName: String

    let initialIndex: Int

    // audioService is kept only for isOnline check and versePath — no playback state read from it
    @EnvironmentObject var audioService: QuranAudioService
    @Environment(\.dismiss) private var dismiss
    @State private var focusedIndex: Int
    @StateObject private var ayahPlayer = AyahAudioPlayer()
    @State private var isSeeking = false
    @State private var seekValue: Double = 0

    init(surahId: Int, ayahs: [Ayah], initialIndex: Int = 0, totalSurahAyahs: Int, surahEnglishName: String, surahArabicName: String) {
        self.surahId = surahId
        self.ayahs = ayahs
        self.initialIndex = initialIndex
        self.totalSurahAyahs = totalSurahAyahs
        self.surahEnglishName = surahEnglishName
        self.surahArabicName = surahArabicName
        self._focusedIndex = State(initialValue: initialIndex)
    }

    private var focusedAyah: Ayah { ayahs[focusedIndex] }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(QuranTheme.goldLight)
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)

            // Header — surah name centered, ayah counter pinned to trailing edge
            ZStack {
                HStack(spacing: 8) {
                    Text(surahEnglishName)
                        .font(.headline)
                        .foregroundColor(QuranTheme.secondaryText)
                    Text("•")
                        .foregroundColor(QuranTheme.gold)
                    Text(surahArabicName)
                        .font(QuranTheme.arabicFont(size: 20))
                        .foregroundColor(QuranTheme.arabicText)
                }
                .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    Text("\(focusedAyah.number) / \(totalSurahAyahs)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(QuranTheme.secondaryText)
                        .padding(.trailing, 16)
                }
            }
            .padding(.bottom, 12)

            Divider()

            // Single ayah display
            ScrollView(showsIndicators: false) {
                ayahCard(focusedAyah)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
            }

            // Always-visible verse navigation controls
            verseControls()
        }
        .background(QuranTheme.pageBackground)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Verse Controls Bar

    private func verseControls() -> some View {
        VStack(spacing: 0) {
            Divider()

            let verseKey = "\(surahId):\(focusedAyah.number)"
            let isThisPlaying = ayahPlayer.playingVerseKey == verseKey

            VStack(spacing: 8) {
                // Prev / Play / Next
                HStack {
                    Button {
                        navigateAyah(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(canGoPrevious ? QuranTheme.goldDark : QuranTheme.secondaryText.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(!canGoPrevious)

                    Spacer()

                    Button {
                        guard let versePath = audioService.selectedReciter?.versePath else { return }
                        ayahPlayer.playVerse(surahId: surahId, ayahNumber: focusedAyah.number, versePath: versePath)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isThisPlaying ? QuranTheme.goldDark : QuranTheme.goldLight.opacity(0.3))
                                .frame(width: 52, height: 52)
                                .overlay(Circle().stroke(QuranTheme.pageBorder.opacity(0.5), lineWidth: 1))

                            if isThisPlaying && ayahPlayer.isBuffering {
                                ProgressView().tint(.white)
                            } else if !audioService.isOnline && !isThisPlaying {
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 18))
                                    .foregroundStyle(QuranTheme.secondaryText.opacity(0.5))
                            } else {
                                Image(systemName: isThisPlaying && ayahPlayer.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(isThisPlaying ? .white : QuranTheme.goldDark)
                                    .offset(x: (isThisPlaying && ayahPlayer.isPlaying) ? 0 : 2)
                            }
                        }
                    }
                    .disabled(!audioService.isOnline && !isThisPlaying)

                    Spacer()

                    Button {
                        navigateAyah(by: +1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(canGoNext ? QuranTheme.goldDark : QuranTheme.secondaryText.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(!canGoNext)
                }

                // Ayah audio progress bar — always visible, fills when audio is active
                ayahProgressBar(isThisPlaying: isThisPlaying)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(QuranTheme.pageBackground)
    }

    // MARK: - Progress Bar

    private func ayahProgressBar(isThisPlaying: Bool) -> some View {
        return VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { isSeeking ? seekValue : (ayahPlayer.duration > 0 ? ayahPlayer.currentTime / ayahPlayer.duration : 0) },
                    set: { seekValue = $0 }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    isSeeking = editing
                    if !editing {
                        ayahPlayer.seek(to: seekValue)
                    }
                }
            )
            .tint(QuranTheme.goldDark)

            HStack {
                Text(formatTime(ayahPlayer.currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(QuranTheme.secondaryText)
                Spacer()
                Text(formatTime(ayahPlayer.duration))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(QuranTheme.secondaryText)
            }
        }
    }

    private func navigateAyah(by offset: Int) {
        let newIndex = focusedIndex + offset
        guard newIndex >= 0, newIndex < ayahs.count else { return }
        let wasPlaying = ayahPlayer.isPlaying
        withAnimation(.easeInOut(duration: 0.25)) { focusedIndex = newIndex }
        if wasPlaying, let versePath = audioService.selectedReciter?.versePath {
            ayahPlayer.playVerse(surahId: surahId, ayahNumber: ayahs[newIndex].number, versePath: versePath)
        }
    }

    private var canGoPrevious: Bool { focusedIndex > 0 }
    private var canGoNext: Bool { focusedIndex < ayahs.count - 1 }

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, !seconds.isNaN, seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    // MARK: - Ayah Card

    private func ayahCard(_ ayah: Ayah) -> some View {
        VStack(spacing: 16) {
            (Text(ayah.arabicText)
                .font(QuranTheme.arabicFont(size: 24))
                .foregroundColor(QuranTheme.arabicText)
            + Text(" \u{FD3F}\(ayah.number.arabicNumeral)\u{FD3E}")
                .font(QuranTheme.arabicFont(size: 28))
                .foregroundColor(QuranTheme.gold))
                .multilineTextAlignment(.center)
                .lineSpacing(12)
                .frame(maxWidth: .infinity)
                .environment(\.layoutDirection, .rightToLeft)

            Text(ayah.translation)
                .font(.body)
                .foregroundColor(QuranTheme.secondaryText)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            AyahsTranslationSheet(
                surahId: 1,
                ayahs: [
                    Ayah(number: 2, arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ", translation: "[All] praise is [due] to Allah, Lord of the worlds -", page: 1, juz: 1),
                    Ayah(number: 3, arabicText: "ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", translation: "The Entirely Merciful, the Especially Merciful,", page: 1, juz: 1),
                ],
                totalSurahAyahs: 7,
                surahEnglishName: "Al-Faatiha",
                surahArabicName: "سُورَةُ ٱلْفَاتِحَةِ"
            )
            .environmentObject(QuranAudioService())
        }
}
