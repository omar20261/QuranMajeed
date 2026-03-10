//
//  AyahsTranslationSheet.swift
//  QuranMajeed
//

import SwiftUI

struct AyahsTranslationSheet: View {
    let ayahs: [Ayah]
    let surahName: String
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
            Text(surahName)
                .font(.headline)
                .foregroundColor(QuranTheme.arabicText)
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
        VStack(spacing: 16) {
            // Ayah number
            HStack {
                Spacer()
                Text("\(ayah.number.arabicNumeral)")
                    .font(QuranTheme.arabicFont(size: 16))
                    .foregroundColor(QuranTheme.pageBackground)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(QuranTheme.gold))
            }

            // Arabic text
            Text(ayah.arabicText)
                .font(QuranTheme.arabicFont(size: 24))
                .foregroundColor(QuranTheme.arabicText)
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
                ayahs: [
                    Ayah(number: 2, arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ", translation: "[All] praise is [due] to Allah, Lord of the worlds -", page: 1, juz: 1),
                    Ayah(number: 3, arabicText: "ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", translation: "The Entirely Merciful, the Especially Merciful,", page: 1, juz: 1),
                    Ayah(number: 4, arabicText: "مَٰلِكِ يَوْمِ ٱلدِّينِ", translation: "Sovereign of the Day of Recompense.", page: 1, juz: 1),
                ],
                surahName: "Al-Faatiha"
            )
        }
}
