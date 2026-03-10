//
//  Theme.swift
//  QuranMajeed
//

import SwiftUI

enum QuranTheme {
    // Background colors
    static let pageBackground = Color(red: 0.98, green: 0.96, blue: 0.90) // Warm cream
    static let pageBorder = Color(red: 0.76, green: 0.60, blue: 0.33) // Gold/amber border

    // Text colors
    static let arabicText = Color(red: 0.20, green: 0.15, blue: 0.10) // Dark brown
    static let secondaryText = Color(red: 0.45, green: 0.35, blue: 0.25) // Medium brown

    // Accent colors
    static let gold = Color(red: 0.80, green: 0.65, blue: 0.30) // Gold accent
    static let goldLight = Color(red: 0.90, green: 0.80, blue: 0.55) // Light gold
    static let goldDark = Color(red: 0.60, green: 0.45, blue: 0.20) // Dark gold

    // Surah banner
    static let bannerBackground = Color(red: 0.25, green: 0.20, blue: 0.15) // Dark brown
    static let bannerText = Color(red: 0.95, green: 0.90, blue: 0.75) // Cream text

    // Fonts
    static func arabicFont(size: CGFloat) -> Font {
        .custom("KFGQPCHAFSUthmanicScript-Regula", size: size)
    }
}
