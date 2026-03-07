//
//  SurahBannerView.swift
//  QuranMajeed
//

import SwiftUI

struct SurahBannerView: View {
    let surah: Surah

    var body: some View {
        HStack(spacing: 0) {
            // Left ornament
            BannerOrnament()

            // Center content
            VStack(spacing: 2) {
                Text(surah.name)
                    .font(QuranTheme.arabicFont(size: 20))
                    .foregroundStyle(QuranTheme.bannerText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(QuranTheme.bannerBackground)

            // Right ornament (mirrored)
            BannerOrnament()
                .scaleEffect(x: -1, y: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct BannerOrnament: View {
    var body: some View {
        ZStack {
            // Pointed end shape
            BannerEndShape()
                .fill(QuranTheme.bannerBackground)
                .frame(width: 20, height: 40)
        }
    }
}

struct BannerEndShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct BismillahView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Left decorative element
            OrnamentalDivider()

            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(QuranTheme.arabicFont(size: 22))
                .foregroundStyle(QuranTheme.arabicText)

            // Right decorative element
            OrnamentalDivider()
                .scaleEffect(x: -1, y: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct OrnamentalDivider: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(QuranTheme.gold)
                .frame(width: 6, height: 6)
            Rectangle()
                .fill(QuranTheme.gold)
                .frame(width: 30, height: 1.5)
        }
    }
}

struct JuzMarkerView: View {
    let juzNumber: Int

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(QuranTheme.gold.opacity(0.5))
                .frame(height: 1)

            Text("۞ الجزء \(juzNumber.arabicNumeral) ۞")
                .font(QuranTheme.arabicFont(size: 14))
                .foregroundStyle(QuranTheme.goldDark)

            Rectangle()
                .fill(QuranTheme.gold.opacity(0.5))
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

extension Int {
    var arabicNumeral: String {
        let arabicNumerals = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        return String(self).map { arabicNumerals[Int(String($0))!] }.joined()
    }
}

#Preview {
    VStack(spacing: 20) {
        SurahBannerView(surah: Surah(
            id: 1,
            name: "سُورَةُ ٱلْفَاتِحَةِ",
            englishName: "Al-Faatiha",
            englishTranslation: "The Opening",
            ayahCount: 7,
            revelationType: "Meccan",
            ayahs: []
        ))
        BismillahView()
        JuzMarkerView(juzNumber: 2)
    }
    .padding()
    .background(QuranTheme.pageBackground)
}
