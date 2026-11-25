//
//  VerseAudioService.swift
//  QuranMajeed
//

import Foundation

class VerseAudioService {
    static let shared = VerseAudioService()

    // mp3quran reciter ID → Quran.com recitation ID
    private static let recitationMapping: [Int: Int] = [
        123: 7,   // Alafasy
        54:  3,   // Sudais
        102: 10,  // Muaiqly
        51:  2,   // Abdul Basit (Murattal)
        118: 6,   // Al-Husary
        112: 8,   // Al-Minshawi
        86:  11,  // Al-Qatami
        92:  12,  // Al-Dosari
    ]
    private static let fallbackRecitationId = 7 // Alafasy

    // Cache: "recitationId-surahId" → [ayahNumber: URL]
    private var cache: [String: [Int: URL]] = [:]

    func verseURL(surahId: Int, ayahNumber: Int, mp3quranReciterId: Int) async -> URL? {
        let recitationId = Self.recitationMapping[mp3quranReciterId] ?? Self.fallbackRecitationId
        let cacheKey = "\(recitationId)-\(surahId)"

        // Return from cache if available
        if let cached = cache[cacheKey] {
            return cached[ayahNumber]
        }

        // Fetch all verses for this surah in one request
        guard let url = URL(string: "https://api.quran.com/api/v4/recitations/\(recitationId)/by_chapter/\(surahId)?per_page=300") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(VerseAudioResponse.self, from: data)

            var surahCache: [Int: URL] = [:]
            for file in response.audioFiles {
                // verse_key format: "surahId:ayahNumber"
                let parts = file.verseKey.split(separator: ":")
                guard parts.count == 2, let ayah = Int(parts[1]) else { continue }

                let fullURLString = file.url.hasPrefix("http")
                    ? file.url
                    : "https://audio.qurancdn.com/\(file.url)"

                if let audioURL = URL(string: fullURLString) {
                    surahCache[ayah] = audioURL
                }
            }

            cache[cacheKey] = surahCache
            return surahCache[ayahNumber]
        } catch {
            print("VerseAudioService fetch error: \(error)")
            return nil
        }
    }

    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Response Models

private struct VerseAudioResponse: Codable {
    let audioFiles: [VerseAudioFile]

    enum CodingKeys: String, CodingKey {
        case audioFiles = "audio_files"
    }
}

private struct VerseAudioFile: Codable {
    let verseKey: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case verseKey = "verse_key"
        case url
    }
}
