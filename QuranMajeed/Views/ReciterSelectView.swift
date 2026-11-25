//
//  ReciterSelectView.swift
//  QuranMajeed
//

import SwiftUI

struct ReciterSelectView: View {
    @EnvironmentObject var audioService: QuranAudioService
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var displayedReciters: [Reciter] {
        if searchText.isEmpty { return audioService.reciters }
        return audioService.reciters.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.englishName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QuranTheme.pageBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(displayedReciters) { reciter in
                            reciterRow(reciter)
                            divider()
                        }
                    }
                }
            }
            .navigationTitle("Select Reciter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(QuranTheme.secondaryText)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search reciters")
        }
    }

    private func reciterRow(_ reciter: Reciter) -> some View {
        Button {
            audioService.selectedReciter = reciter
            dismiss()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reciter.name)
                        .font(QuranTheme.arabicFont(size: 17))
                        .foregroundStyle(QuranTheme.arabicText)
                    Text(reciter.englishName)
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                }

                Spacer()

                if audioService.selectedReciter?.id == reciter.id {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(QuranTheme.goldDark)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(QuranTheme.pageBackground)
    }

    private func divider() -> some View {
        Rectangle()
            .fill(QuranTheme.pageBorder.opacity(0.25))
            .frame(height: 1)
            .padding(.leading, 20)
    }
}
