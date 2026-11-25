//
//  Reciter.swift
//  QuranMajeed
//

import Foundation

struct Reciter: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String         // Arabic
    let englishName: String
    let surahPath: String    // QuranicAudio relative path
    let versePath: String    // EveryAyah folder name

    // Backward-compatible helpers used in existing views
    var rewaya: String { englishName }
    var surahCount: Int { 114 }

    func surahURL(for surahId: Int) -> URL? {
        URL(string: "https://download.quranicaudio.com/quran/\(surahPath)\(String(format: "%03d", surahId)).mp3")
    }

    func verseURL(surahId: Int, ayahNumber: Int) -> URL? {
        URL(string: "https://everyayah.com/data/\(versePath)/\(String(format: "%03d", surahId))\(String(format: "%03d", ayahNumber)).mp3")
    }

    // MARK: - Hardcoded list (QuranicAudio + EveryAyah — both open CDNs, no auth)

    static let all: [Reciter] = [
        Reciter(id: 2,  name: "عبدالله بصفر",           englishName: "Abdullah Basfar",        surahPath: "abdullaah_basfar/",                  versePath: "Abdullah_Basfar_192kbps"),
        Reciter(id: 5,  name: "مشاري راشد العفاسي",      englishName: "Mishary Rashid Alafasy",  surahPath: "mishaari_raashid_al_3afaasee/",       versePath: "Alafasy_128kbps"),
        Reciter(id: 7,  name: "عبدالرحمن السديس",        englishName: "Abdurrahman As-Sudais",   surahPath: "abdurrahmaan_as-sudays/",             versePath: "Abdurrahmaan_As-Sudais_192kbps"),
        Reciter(id: 65, name: "ماهر المعيقلي",           englishName: "Maher Al-Muaiqly",        surahPath: "maher_256/",                          versePath: "Maher_AlMuaiqly_128kbps"),
        Reciter(id: 37, name: "عبد الباسط عبد الصمد",    englishName: "Abdul Basit Murattal",    surahPath: "abdul_basit_murattal/",               versePath: "Abdul_Baset_Murattal_192kbps"),
        Reciter(id: 16, name: "محمود خليل الحصري",       englishName: "Mahmoud Khalil Al-Husary", surahPath: "mahmood_khaleel_al-husaree/",         versePath: "Husary_128kbps"),
        Reciter(id: 6,  name: "محمد صديق المنشاوي",      englishName: "Muhammad Siddiq Al-Minshawi", surahPath: "muhammad_siddeeq_al-minshaawee/", versePath: "Minshawi_Murattal_128kbps"),
        Reciter(id: 13, name: "سعد الغامدي",             englishName: "Saad Al-Ghamdi",          surahPath: "sa3d_al-ghaamidi/complete/",          versePath: "Saad_Al-Ghamdi_128kbps"),
        Reciter(id: 3,  name: "أبو بكر الشاطري",         englishName: "Abu Bakr Ash-Shatri",     surahPath: "abu_bakr_ash-shaatree/",              versePath: "Abu_Bakr_Ash-Shaatree_128kbps"),
        Reciter(id: 8,  name: "علي الحذيفي",             englishName: "Ali Al-Huthaify",         surahPath: "huthayfi/",                           versePath: "Hudhaify_128kbps"),
    ]

    static let defaultReciter = all[0] // Abdullah Basfar
}
