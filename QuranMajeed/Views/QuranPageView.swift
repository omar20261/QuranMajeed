//
//  QuranPageView.swift
//  QuranMajeed
//

import SwiftUI

struct QuranPageView: View {
    @EnvironmentObject var dataService: QuranDataService
    @State private var currentPage: Int = 1
    @State private var showSurahList = false

    var body: some View {
        ZStack {
            QuranTheme.pageBackground
                .ignoresSafeArea()

            if dataService.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(QuranTheme.gold)
                    Text("Loading Quran...")
                        .font(QuranTheme.arabicFont(size: 16))
                        .foregroundStyle(QuranTheme.secondaryText)
                }
            } else if let error = dataService.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(QuranTheme.goldDark)
                    Text(error)
                        .foregroundStyle(QuranTheme.secondaryText)
                }
            } else {
                VStack(spacing: 0) {
                    pageView
                    toolbar
                }
            }
        }
        .onAppear {
            currentPage = dataService.lastReadPage
        }
        .sheet(isPresented: $showSurahList) {
            SurahListSheet(onSurahSelected: { surah in
                navigateToSurah(surah)
            })
        }
    }

    private var pageView: some View {
        TabView(selection: $currentPage) {
            ForEach(dataService.pages) { page in
                PageContentView(page: page)
                    .tag(page.pageNumber)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .environment(\.layoutDirection, .rightToLeft)
        .onChange(of: currentPage) { newPage in
            dataService.saveReadPosition(page: newPage)
        }
    }

    private var toolbar: some View {
        ControlToolbar(
            currentPage: currentPage,
            totalPages: QuranDataService.totalPages,
            juz: dataService.getPage(number: currentPage)?.juz ?? 1,
            onSurahListTap: {
                showSurahList = true
            }
        )
    }

    private func navigateToSurah(_ surah: Surah) {
        let page = dataService.getStartingPage(for: surah)
        withAnimation {
            currentPage = page
        }
        showSurahList = false
    }
}

#Preview {
    QuranPageView()
        .environmentObject(QuranDataService())
}
