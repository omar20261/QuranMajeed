//
//  Surah.swift
//  QuranMajeed
//

import Foundation

struct Surah: Identifiable, Codable {
    let id: Int
    let name: String
    let englishName: String
    let englishTranslation: String
    let ayahCount: Int
    let revelationType: String
    let ayahs: [Ayah]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case englishName
        case englishTranslation
        case ayahCount
        case revelationType
        case ayahs
    }
}
