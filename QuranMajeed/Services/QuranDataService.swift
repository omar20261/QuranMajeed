//
//  QuranDataService.swift
//  QuranMajeed
//

import Foundation
import Combine

@MainActor
class QuranDataService: ObservableObject {
    @Published var surahs: [Surah] = []
    @Published var pages: [QuranPage] = []
    @Published var isLoading = true
    @Published var error: String?

    // Last read position (page-based)
    @Published var lastReadPage: Int {
        didSet {
            UserDefaults.standard.set(lastReadPage, forKey: "lastReadPage")
        }
    }

    // Total pages in the Quran
    static let totalPages = 604

    init() {
        lastReadPage = UserDefaults.standard.integer(forKey: "lastReadPage")
        if lastReadPage == 0 {
            lastReadPage = 1
        }
        loadQuranData()
    }

    func saveReadPosition(page: Int) {
        lastReadPage = page
    }

    func getStartingPage(for surah: Surah) -> Int {
        surah.ayahs.first?.page ?? 1
    }

    private func loadQuranData() {
        guard let url = Bundle.main.url(forResource: "quran", withExtension: "json") else {
            error = "Could not find quran.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let quranData = try decoder.decode(QuranData.self, from: data)
            surahs = quranData.surahs
            pages = organizeByPages()
            isLoading = false
        } catch {
            self.error = "Failed to load Quran data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func organizeByPages() -> [QuranPage] {
        var pageDict: [Int: [PageAyah]] = [:]

        for surah in surahs {
            for (index, ayah) in surah.ayahs.enumerated() {
                let pageAyah = PageAyah(
                    surah: surah,
                    ayah: ayah,
                    isFirstAyahOfSurah: index == 0
                )

                if pageDict[ayah.page] == nil {
                    pageDict[ayah.page] = []
                }
                pageDict[ayah.page]?.append(pageAyah)
            }
        }

        return (1...Self.totalPages).compactMap { pageNum in
            guard let ayahs = pageDict[pageNum], !ayahs.isEmpty else {
                return nil
            }
            return QuranPage(pageNumber: pageNum, ayahs: ayahs)
        }
    }

    func getSurah(by id: Int) -> Surah? {
        surahs.first { $0.id == id }
    }

    func getPage(number: Int) -> QuranPage? {
        pages.first { $0.pageNumber == number }
    }
}

struct QuranData: Codable {
    let surahs: [Surah]
}
