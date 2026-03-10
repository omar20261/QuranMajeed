//
//  PageContentView.swift
//  QuranMajeed
//

import SwiftUI

struct SelectedAyah: Identifiable {
    let id = UUID()
    let ayah: Ayah
    let surahEnglishName: String
    let surahArabicName: String
}

struct PageContentView: View {
    let page: QuranPage
    @State private var selectedAyah: SelectedAyah?

    // Store ayahs by surah-ayah key for lookup when tapped
    private var ayahLookup: [String: (ayah: Ayah, surahEnglishName: String, surahArabicName: String)] {
        var lookup: [String: (Ayah, String, String)] = [:]
        for pageAyah in page.ayahs {
            let key = "\(pageAyah.surah.id)-\(pageAyah.ayah.number)"
            lookup[key] = (pageAyah.ayah, pageAyah.surah.englishName, pageAyah.surah.name)
        }
        return lookup
    }

    var body: some View {
        ZStack {
            // Background
            QuranTheme.pageBackground
                .ignoresSafeArea()

            // Page frame
            PageFrameView {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 0) {
                            Color.clear
                                .frame(height: 0)
                                .id("top")

                            ForEach(groupedContent, id: \.id) { section in
                                // Juz marker if new juz starts
                                if let juzNumber = section.newJuzNumber {
                                    JuzMarkerView(juzNumber: juzNumber)
                                }

                                if section.showSurahBanner {
                                    SurahBannerView(surah: section.surah)
                                }

                                if section.showBismillah {
                                    BismillahView()
                                }

                                flowingTextView(for: section.ayahs, surahName: section.surah.englishName)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onAppear {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
            .padding(12)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(item: $selectedAyah) { selected in
            AyahsTranslationSheet(
                ayahs: [selected.ayah],
                surahEnglishName: selected.surahEnglishName,
                surahArabicName: selected.surahArabicName
            )
        }
    }

    private var groupedContent: [PageSection] {
        var sections: [PageSection] = []
        var currentSurahId: Int?
        var currentJuz: Int?

        for pageAyah in page.ayahs {
            let isNewJuz = currentJuz != pageAyah.ayah.juz
            let juzToShow = isNewJuz ? pageAyah.ayah.juz : nil

            if pageAyah.surah.id != currentSurahId {
                sections.append(PageSection(
                    surah: pageAyah.surah,
                    showSurahBanner: pageAyah.isFirstAyahOfSurah,
                    showBismillah: pageAyah.showBismillah,
                    newJuzNumber: juzToShow,
                    ayahs: [pageAyah]
                ))
                currentSurahId = pageAyah.surah.id
            } else {
                // Check if juz changed mid-section
                if isNewJuz {
                    sections.append(PageSection(
                        surah: pageAyah.surah,
                        showSurahBanner: false,
                        showBismillah: false,
                        newJuzNumber: juzToShow,
                        ayahs: [pageAyah]
                    ))
                } else {
                    sections[sections.count - 1].ayahs.append(pageAyah)
                }
            }
            currentJuz = pageAyah.ayah.juz
        }

        return sections
    }

    private let bismillahPattern = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
    private let kfgqpcBismillahPattern = "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ"

    @ViewBuilder
    private func flowingTextView(for ayahs: [PageAyah], surahName: String) -> some View {
        // Filter out first ayah of Surah 1 (it's only Bismillah)
        let displayAyahs = ayahs.filter { pageAyah in
            !(pageAyah.surah.id == 1 && pageAyah.ayah.number == 1)
        }

        let attributedString = buildAttributedString(for: displayAyahs)

        Text(attributedString)
            .lineSpacing(20)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .tint(QuranTheme.arabicText)
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "ayah",
                   let host = url.host,
                   let data = ayahLookup[host] {
                    selectedAyah = SelectedAyah(
                        ayah: data.ayah,
                        surahEnglishName: data.surahEnglishName,
                        surahArabicName: data.surahArabicName
                    )
                    return .handled
                }
                return .discarded
            })
    }

    private func buildAttributedString(for ayahs: [PageAyah]) -> AttributedString {
        var result = AttributedString()

        for pageAyah in ayahs {
            // Remove Bismillah from first ayah text (shown in decoration)
            var text = pageAyah.ayah.arabicText
            if pageAyah.ayah.number == 1 && pageAyah.surah.id != 9 {
                text = text
                    .replacingOccurrences(of: bismillahPattern, with: "")
                    .replacingOccurrences(of: kfgqpcBismillahPattern, with: "")
                    .trimmingCharacters(in: .whitespaces)
            }

            let linkURL = URL(string: "ayah://\(pageAyah.surah.id)-\(pageAyah.ayah.number)")

            // Ayah text (tappable)
            var ayahText = AttributedString(text)
            ayahText.font = QuranTheme.uiArabicFont(size: 24)
            ayahText.foregroundColor = QuranTheme.arabicText
            ayahText.link = linkURL
            result.append(ayahText)

            // Marker (also tappable, same link)
            let markerString = " \u{FD3F}\(pageAyah.ayah.number.arabicNumeral)\u{FD3E} "
            var marker = AttributedString(markerString)
            marker.font = QuranTheme.uiArabicFont(size: 20)
            marker.foregroundColor = QuranTheme.gold
            marker.link = linkURL
            result.append(marker)
        }

        return result
    }
}

struct PageFrameView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(QuranTheme.pageBackground)
            .overlay(
                // Double border frame
                ZStack {
                    // Outer border
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(QuranTheme.pageBorder, lineWidth: 2)

                    // Inner border
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(QuranTheme.pageBorder.opacity(0.5), lineWidth: 1)
                        .padding(4)

                    // Corner ornaments
                    GeometryReader { geo in
                        ForEach(0..<4, id: \.self) { corner in
                            CornerOrnament()
                                .position(cornerPosition(for: corner, in: geo.size))
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func cornerPosition(for corner: Int, in size: CGSize) -> CGPoint {
        switch corner {
        case 0: return CGPoint(x: 16, y: 16) // Top-left
        case 1: return CGPoint(x: size.width - 16, y: 16) // Top-right
        case 2: return CGPoint(x: 16, y: size.height - 16) // Bottom-left
        case 3: return CGPoint(x: size.width - 16, y: size.height - 16) // Bottom-right
        default: return .zero
        }
    }
}

struct CornerOrnament: View {
    var body: some View {
        Circle()
            .fill(QuranTheme.gold)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(QuranTheme.goldDark, lineWidth: 1)
            )
    }
}

private struct PageSection: Identifiable {
    let surah: Surah
    let showSurahBanner: Bool
    let showBismillah: Bool
    let newJuzNumber: Int?
    var ayahs: [PageAyah]

    var id: String {
        "\(surah.id)-\(ayahs.first?.ayah.number ?? 0)-\(newJuzNumber ?? 0)"
    }
}

#Preview {
    PageContentView(page: QuranPage(
        pageNumber: 1,
        ayahs: [
            PageAyah(
                surah: Surah(
                    id: 1,
                    name: "سُورَةُ ٱلْفَاتِحَةِ",
                    englishName: "Al-Faatiha",
                    englishTranslation: "The Opening",
                    ayahCount: 7,
                    revelationType: "Meccan",
                    ayahs: []
                ),
                ayah: Ayah(number: 1, arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", translation: "", page: 1, juz: 1),
                isFirstAyahOfSurah: true
            ),
            PageAyah(
                surah: Surah(
                    id: 1,
                    name: "سُورَةُ ٱلْفَاتِحَةِ",
                    englishName: "Al-Faatiha",
                    englishTranslation: "The Opening",
                    ayahCount: 7,
                    revelationType: "Meccan",
                    ayahs: []
                ),
                ayah: Ayah(number: 2, arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ", translation: "", page: 1, juz: 1),
                isFirstAyahOfSurah: false
            )
        ]
    ))
}
