//
//  SurahListView.swift
//  QuranMajeed
//

import SwiftUI

struct SurahListSheet: View {
    @EnvironmentObject var dataService: QuranDataService
    @Environment(\.dismiss) private var dismiss

    let onSurahSelected: (Surah) -> Void
    let onPageSelected: (Int) -> Void

    private var sortedBookmarks: [Int] {
        dataService.bookmarkedPages.sorted()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Bookmarks Section
                    if !sortedBookmarks.isEmpty {
                        BookmarksSectionView(
                            bookmarks: sortedBookmarks,
                            dataService: dataService,
                            onPageSelected: { page in
                                onPageSelected(page)
                                dismiss()
                            },
                            onDeleteBookmark: { page in
                                dataService.toggleBookmark(page: page)
                            }
                        )

                        SectionHeaderView(title: "Surahs")
                    }

                    ForEach(dataService.surahs) { surah in
                        Button {
                            onSurahSelected(surah)
                            dismiss()
                        } label: {
                            SurahRowView(
                                surah: surah,
                                pageNumber: dataService.getStartingPage(for: surah)
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(QuranTheme.pageBorder.opacity(0.3))
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(QuranTheme.pageBackground)
            .navigationTitle("Surahs - السور")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(QuranTheme.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.gray)
                            .padding(10)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

struct SurahRowView: View {
    let surah: Surah
    let pageNumber: Int

    var body: some View {
        HStack(spacing: 16) {
            // Surah number
            Text("\(surah.id)")
                .font(.headline)
                .foregroundStyle(QuranTheme.bannerText)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(QuranTheme.bannerBackground)
                )

            // Surah info
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .font(.headline)
                    .foregroundStyle(QuranTheme.arabicText)
                HStack {
                    Text(surah.englishTranslation)
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                    Text("•")
                        .foregroundStyle(QuranTheme.secondaryText)
                    Text("Page \(pageNumber)")
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                }
            }

            Spacer()

            // Arabic name
            Text(surah.name)
                .font(QuranTheme.arabicFont(size: 20))
                .foregroundStyle(QuranTheme.arabicText)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(QuranTheme.pageBackground)
    }
}

struct BookmarksSectionView: View {
    let bookmarks: [Int]
    let dataService: QuranDataService
    let onPageSelected: (Int) -> Void
    let onDeleteBookmark: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: "Bookmarks")

            ForEach(bookmarks, id: \.self) { page in
                Button {
                    onPageSelected(page)
                } label: {
                    BookmarkRowView(
                        page: page,
                        surahName: getSurahName(for: page),
                        juz: dataService.getPage(number: page)?.juz ?? 1,
                        onDelete: {
                            onDeleteBookmark(page)
                        }
                    )
                }
                .buttonStyle(.plain)

                Divider()
                    .background(QuranTheme.pageBorder.opacity(0.3))
                    .padding(.horizontal, 16)
            }
        }
    }

    private func getSurahName(for page: Int) -> String {
        guard let quranPage = dataService.getPage(number: page),
              let firstAyah = quranPage.ayahs.first else {
            return ""
        }
        return firstAyah.surah.englishName
    }
}

struct BookmarkRowView: View {
    let page: Int
    let surahName: String
    let juz: Int
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(QuranTheme.goldDark)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(QuranTheme.bannerBackground)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Page \(page)")
                    .font(.headline)
                    .foregroundStyle(QuranTheme.arabicText)
                HStack {
                    Text(surahName)
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                    Text("•")
                        .foregroundStyle(QuranTheme.secondaryText)
                    Text("Juz \(juz)")
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(QuranTheme.secondaryText)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(QuranTheme.pageBorder.opacity(0.5))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(QuranTheme.pageBackground)
    }
}

struct SectionHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(QuranTheme.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(QuranTheme.pageBorder.opacity(0.3))
    }
}

#Preview {
    SurahListSheet(onSurahSelected: { _ in }, onPageSelected: { _ in })
        .environmentObject(QuranDataService())
}
