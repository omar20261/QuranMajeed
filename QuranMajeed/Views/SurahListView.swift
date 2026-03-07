//
//  SurahListView.swift
//  QuranMajeed
//

import SwiftUI

struct SurahListSheet: View {
    @EnvironmentObject var dataService: QuranDataService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    let onSurahSelected: (Surah) -> Void

    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return dataService.surahs
        }
        return dataService.surahs.filter { surah in
            surah.englishName.localizedCaseInsensitiveContains(searchText) ||
            surah.englishTranslation.localizedCaseInsensitiveContains(searchText) ||
            surah.name.contains(searchText) ||
            String(surah.id).contains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredSurahs) { surah in
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
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search surahs")
            .navigationTitle("Surahs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
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
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor)
                )

            // Surah info
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .font(.headline)
                HStack {
                    Text(surah.englishTranslation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("Page \(pageNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Arabic name
            Text(surah.name)
                .font(.title2)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SurahListSheet(onSurahSelected: { _ in })
        .environmentObject(QuranDataService())
}
