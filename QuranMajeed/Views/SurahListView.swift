//
//  SurahListView.swift
//  QuranMajeed
//

import SwiftUI

struct SurahListSheet: View {
    @EnvironmentObject var dataService: QuranDataService
    @Environment(\.dismiss) private var dismiss

    let onSurahSelected: (Surah) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
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

#Preview {
    SurahListSheet(onSurahSelected: { _ in })
        .environmentObject(QuranDataService())
}
