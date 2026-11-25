//
//  ReciterSelectView.swift
//  QuranMajeed
//

import SwiftUI

struct ReciterSelectView: View {
    @EnvironmentObject var audioService: QuranAudioService
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @AppStorage("reciterListExpanded") private var showAll = false

    // Popular reciter IDs in preferred order
    private static let popularIds: [Int] = [123, 54, 102, 92, 86, 51, 118, 112, 74, 5]

    private var popularReciters: [Reciter] {
        let ids = Self.popularIds
        return ids.compactMap { id in audioService.reciters.first { $0.id == id } }
    }

    private var otherReciters: [Reciter] {
        let popularSet = Set(Self.popularIds)
        return audioService.reciters.filter { !popularSet.contains($0.id) }
    }

    private var searchResults: [Reciter] {
        audioService.reciters.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.rewaya.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QuranTheme.pageBackground.ignoresSafeArea()

                if audioService.isLoadingReciters {
                    VStack(spacing: 16) {
                        ProgressView().tint(QuranTheme.gold)
                        Text("Loading reciters...")
                            .font(.subheadline)
                            .foregroundStyle(QuranTheme.secondaryText)
                    }
                } else if audioService.reciters.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.largeTitle)
                            .foregroundStyle(QuranTheme.secondaryText)
                        Text("Could not load reciters")
                            .foregroundStyle(QuranTheme.secondaryText)
                        Button("Retry") { Task { await audioService.fetchReciters() } }
                            .foregroundStyle(QuranTheme.goldDark)
                    }
                } else if !searchText.isEmpty {
                    // Search results — flat list
                    reciterList(searchResults)
                } else {
                    // Default — popular + expandable rest
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            sectionHeader("Popular")
                            ForEach(popularReciters) { reciter in
                                reciterRow(reciter)
                                divider()
                            }

                            if showAll {
                                sectionHeader("All Reciters")
                                ForEach(otherReciters) { reciter in
                                    reciterRow(reciter)
                                    divider()
                                }
                            } else if !otherReciters.isEmpty {
                                showMoreButton
                            }
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

    // MARK: - Components

    private func reciterList(_ reciters: [Reciter]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(reciters) { reciter in
                    reciterRow(reciter)
                    divider()
                }
            }
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
                    Text(reciter.rewaya)
                        .font(.caption)
                        .foregroundStyle(QuranTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if audioService.selectedReciter?.id == reciter.id {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(QuranTheme.goldDark)
                    }
                    Text("\(reciter.surahCount) surahs")
                        .font(.caption2)
                        .foregroundStyle(QuranTheme.secondaryText.opacity(0.8))
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(QuranTheme.pageBackground)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(QuranTheme.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 6)
        .background(QuranTheme.pageBackground)
    }

    private func divider() -> some View {
        Rectangle()
            .fill(QuranTheme.pageBorder.opacity(0.25))
            .frame(height: 1)
            .padding(.leading, 20)
    }

    private var showMoreButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAll = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.down.circle")
                    .font(.system(size: 16))
                Text("Show \(otherReciters.count) more reciters")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(QuranTheme.goldDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(QuranTheme.goldLight.opacity(0.2))
            )
        }
        .padding(.top, 8)
    }
}
