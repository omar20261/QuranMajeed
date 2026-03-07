//
//  QuranPage.swift
//  QuranMajeed
//

import Foundation

struct QuranPage: Identifiable {
    let pageNumber: Int
    var ayahs: [PageAyah]

    var id: Int { pageNumber }

    var juz: Int {
        ayahs.first?.ayah.juz ?? 1
    }
}

struct PageAyah: Identifiable {
    let surah: Surah
    let ayah: Ayah
    let isFirstAyahOfSurah: Bool

    var id: String {
        "\(surah.id)-\(ayah.number)"
    }

    var showBismillah: Bool {
        isFirstAyahOfSurah && surah.id != 9
    }
}
