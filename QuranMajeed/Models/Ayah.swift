//
//  Ayah.swift
//  QuranMajeed
//

import Foundation

struct Ayah: Identifiable, Codable {
    let number: Int
    let arabicText: String
    let translation: String
    let page: Int
    let juz: Int

    var id: Int { number }

    enum CodingKeys: String, CodingKey {
        case number
        case arabicText = "arabic"
        case translation
        case page
        case juz
    }
}
