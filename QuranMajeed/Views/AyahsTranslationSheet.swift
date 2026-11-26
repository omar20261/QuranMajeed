//
//  AyahsTranslationSheet.swift
//  QuranMajeed
//

import SwiftUI

struct AyahsTranslationSheet: View {
    let surahId: Int
    let ayahs: [Ayah]
    let surahEnglishName: String
    let surahArabicName: String

    let initialIndex: Int

    @EnvironmentObject var audioService: QuranAudioService
    @Environment(\.dismiss) private var dismiss
    @State private var focusedIndex: Int

    init(surahId: Int, ayahs: [Ayah], initialIndex: Int = 0, surahEnglishName: String, surahArabicName: String) {
        self.surahId = surahId
        self.ayahs = ayahs
        self.initialIndex = initialIndex
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

            // Header
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
            .padding(.bottom, 12)

            Divider()

            // Single ayah display
            ScrollView(showsIndicators: false) {
                ayahCard(focusedAyah)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
            }
            .onChange(of: audioService.playingVerseKey) { _ in
                if let key = audioService.playingVerseKey,
                   let ayahNumber = Int(key.split(separator: ":").last ?? ""),
                   let idx = ayahs.firstIndex(where: { $0.number == ayahNumber }) {
                    focusedIndex = idx
                }
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
            let isThisPlaying = audioService.playingVerseKey == verseKey

            VStack(spacing: 4) {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { focusedIndex -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(canGoPrevious ? QuranTheme.goldDark : QuranTheme.secondaryText.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(!canGoPrevious)

                    Spacer()

                    Button {
                        audioService.playVerse(surahId: surahId, ayahNumber: focusedAyah.number)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isThisPlaying ? QuranTheme.goldDark : QuranTheme.goldLight.opacity(0.3))
                                .frame(width: 52, height: 52)
                                .overlay(Circle().stroke(QuranTheme.pageBorder.opacity(0.5), lineWidth: 1))

                            if isThisPlaying && audioService.isBuffering {
                                ProgressView().tint(.white)
                            } else if !audioService.isOnline && !isThisPlaying {
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 18))
                                    .foregroundStyle(QuranTheme.secondaryText.opacity(0.5))
                            } else {
                                Image(systemName: isThisPlaying && audioService.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(isThisPlaying ? .white : QuranTheme.goldDark)
                                    .offset(x: (isThisPlaying && audioService.isPlaying) ? 0 : 2)
                            }
                        }
                    }
                    .disabled(!audioService.isOnline && !isThisPlaying)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { focusedIndex += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(canGoNext ? QuranTheme.goldDark : QuranTheme.secondaryText.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(!canGoNext)
                }

                Text("\(focusedIndex + 1) / \(ayahs.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(QuranTheme.secondaryText)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(QuranTheme.pageBackground)
    }

    private var canGoPrevious: Bool { focusedIndex > 0 }
    private var canGoNext: Bool { focusedIndex < ayahs.count - 1 }

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
                surahEnglishName: "Al-Faatiha",
                surahArabicName: "سُورَةُ ٱلْفَاتِحَةِ"
            )
            .environmentObject(QuranAudioService())
        }
}
