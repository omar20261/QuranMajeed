//
//  VerseAudioService.swift
//  QuranMajeed
//

import Foundation

class VerseAudioService {
    static let shared = VerseAudioService()

    /// Builds a direct EveryAyah CDN URL for a single verse. No network call needed.
    func verseURL(surahId: Int, ayahNumber: Int, versePath: String) -> URL? {
        let surah = String(format: "%03d", surahId)
        let ayah  = String(format: "%03d", ayahNumber)
        return URL(string: "https://everyayah.com/data/\(versePath)/\(surah)\(ayah).mp3")
    }
}
