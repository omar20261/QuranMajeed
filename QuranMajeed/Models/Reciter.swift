//
//  Reciter.swift
//  QuranMajeed
//

import Foundation

struct Moshaf: Codable, Equatable, Hashable {
    let id: Int
    let name: String       // e.g. "حفص عن عاصم - مرتل"
    let server: String     // base URL with trailing slash
    let surahTotal: Int
    let surahList: String  // comma-separated available surah IDs

    enum CodingKeys: String, CodingKey {
        case id, name, server
        case surahTotal = "surah_total"
        case surahList  = "surah_list"
    }

    func audioURL(for surahId: Int) -> URL? {
        URL(string: "\(server)\(String(format: "%03d", surahId)).mp3")
    }

    var availableSurahs: Set<Int> {
        Set(surahList.split(separator: ",").compactMap { Int($0) })
    }
}

struct Reciter: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let letter: String
    let moshaf: [Moshaf]

    // Pick the moshaf with the most available surahs
    var primaryMoshaf: Moshaf? {
        moshaf.max { $0.surahTotal < $1.surahTotal }
    }

    var rewaya: String { primaryMoshaf?.name ?? "" }
    var surahCount: Int { primaryMoshaf?.surahTotal ?? 0 }

    func audioURL(for surahId: Int) -> URL? {
        primaryMoshaf?.audioURL(for: surahId)
    }
}

struct RecitersResponse: Codable {
    let reciters: [Reciter]
}
