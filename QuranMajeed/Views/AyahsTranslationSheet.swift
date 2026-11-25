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

    @EnvironmentObject var audioService: QuranAudioService
    @Environment(\.dismiss) private var dismiss

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

            // Ayahs list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(ayahs) { ayah in
                        ayahCard(ayah)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            }
        }
        .background(QuranTheme.pageBackground)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private func ayahCard(_ ayah: Ayah) -> some View {
        let verseKey = "\(surahId):\(ayah.number)"
        let isThisVersePlaying = audioService.playingVerseKey == verseKey

        return VStack(spacing: 16) {
            // Arabic text with ayah number at the end
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

            // Translation
            Text(ayah.translation)
                .font(.body)
                .foregroundColor(QuranTheme.secondaryText)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Listen button
            Button {
                audioService.playVerse(surahId: surahId, ayahNumber: ayah.number)
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(isThisVersePlaying ? QuranTheme.goldDark : QuranTheme.goldLight.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .overlay(Circle().stroke(QuranTheme.pageBorder.opacity(0.5), lineWidth: 1))

                        if isThisVersePlaying && audioService.isBuffering {
                            ProgressView()
                                .tint(isThisVersePlaying ? .white : QuranTheme.goldDark)
                        } else {
                            Image(systemName: isThisVersePlaying && audioService.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(isThisVersePlaying ? .white : QuranTheme.goldDark)
                                .offset(x: (isThisVersePlaying && audioService.isPlaying) ? 0 : 2)
                        }
                    }

                    Text(isThisVersePlaying && audioService.isPlaying ? "Pause" : "Listen")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isThisVersePlaying ? QuranTheme.goldDark : QuranTheme.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)

            if ayah.id != ayahs.last?.id {
                Rectangle()
                    .fill(QuranTheme.gold.opacity(0.2))
                    .frame(height: 1)
                    .padding(.top, 8)
            }
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
