//
//  Theme.swift
//  QuranMajeed
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case parchment = "Parchment"
    case night = "Night"
    case paper = "Paper"

    var pageBackground: Color {
        switch self {
        case .parchment: return Color(red: 0.98, green: 0.96, blue: 0.90)
        case .night:     return Color(red: 0.10, green: 0.08, blue: 0.06)
        case .paper:     return Color(red: 1.00, green: 1.00, blue: 1.00)
        }
    }

    var pageBorder: Color {
        switch self {
        case .parchment: return Color(red: 0.76, green: 0.60, blue: 0.33)
        case .night:     return Color(red: 0.45, green: 0.35, blue: 0.20)
        case .paper:     return Color(red: 0.80, green: 0.72, blue: 0.55)
        }
    }

    var arabicText: Color {
        switch self {
        case .parchment: return Color(red: 0.20, green: 0.15, blue: 0.10)
        case .night:     return Color(red: 0.92, green: 0.88, blue: 0.78)
        case .paper:     return Color(red: 0.10, green: 0.08, blue: 0.06)
        }
    }

    var secondaryText: Color {
        switch self {
        case .parchment: return Color(red: 0.45, green: 0.35, blue: 0.25)
        case .night:     return Color(red: 0.60, green: 0.52, blue: 0.40)
        case .paper:     return Color(red: 0.40, green: 0.33, blue: 0.25)
        }
    }

    var gold: Color {
        switch self {
        case .parchment: return Color(red: 0.80, green: 0.65, blue: 0.30)
        case .night:     return Color(red: 0.85, green: 0.68, blue: 0.32)
        case .paper:     return Color(red: 0.72, green: 0.58, blue: 0.25)
        }
    }

    var goldLight: Color {
        switch self {
        case .parchment: return Color(red: 0.90, green: 0.80, blue: 0.55)
        case .night:     return Color(red: 0.75, green: 0.60, blue: 0.28)
        case .paper:     return Color(red: 0.85, green: 0.75, blue: 0.50)
        }
    }

    var goldDark: Color {
        switch self {
        case .parchment: return Color(red: 0.60, green: 0.45, blue: 0.20)
        case .night:     return Color(red: 0.70, green: 0.55, blue: 0.25)
        case .paper:     return Color(red: 0.55, green: 0.42, blue: 0.18)
        }
    }

    var bannerBackground: Color {
        switch self {
        case .parchment: return Color(red: 0.25, green: 0.20, blue: 0.15)
        case .night:     return Color(red: 0.18, green: 0.14, blue: 0.10)
        case .paper:     return Color(red: 0.20, green: 0.16, blue: 0.12)
        }
    }

    var bannerText: Color {
        switch self {
        case .parchment: return Color(red: 0.95, green: 0.90, blue: 0.75)
        case .night:     return Color(red: 0.92, green: 0.88, blue: 0.78)
        case .paper:     return Color(red: 0.95, green: 0.90, blue: 0.75)
        }
    }

    var toolbarColorScheme: ColorScheme {
        switch self {
        case .night: return .dark
        default:     return .light
        }
    }
}

// MARK: - Theme manager (drives SwiftUI re-renders)

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var current: AppTheme
    @Published var fontSize: CGFloat
    private var cancellables = Set<AnyCancellable>()

    static let minFontSize: CGFloat = 18
    static let maxFontSize: CGFloat = 46
    static let defaultFontSize: CGFloat = 32

    private init() {
        let saved = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.parchment.rawValue
        current = AppTheme(rawValue: saved) ?? .parchment
        fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize").nonZero ?? Float(ThemeManager.defaultFontSize))

        $current.sink { UserDefaults.standard.set($0.rawValue, forKey: "selectedTheme") }.store(in: &cancellables)
        $fontSize.sink { UserDefaults.standard.set(Float($0), forKey: "fontSize") }.store(in: &cancellables)
    }
}

// MARK: - Global theme accessor

enum QuranTheme {
    static var current: AppTheme { ThemeManager.shared.current }

    static var pageBackground: Color { current.pageBackground }
    static var pageBorder: Color     { current.pageBorder }
    static var arabicText: Color     { current.arabicText }
    static var secondaryText: Color  { current.secondaryText }
    static var gold: Color           { current.gold }
    static var goldLight: Color      { current.goldLight }
    static var goldDark: Color       { current.goldDark }
    static var bannerBackground: Color { current.bannerBackground }
    static var bannerText: Color     { current.bannerText }
    static var fontSize: CGFloat     { ThemeManager.shared.fontSize }
    static var markerFontSize: CGFloat { ThemeManager.shared.fontSize + 4 }

    // Fonts
    static func arabicFont(size: CGFloat) -> Font {
        .custom("KFGQPCHAFSUthmanicScript-Regula", size: size)
    }

    static func uiArabicFont(size: CGFloat) -> UIFont {
        UIFont(name: "KFGQPCHAFSUthmanicScript-Regula", size: size) ?? .systemFont(ofSize: size)
    }
}

private extension Float {
    var nonZero: Float? { self == 0 ? nil : self }
}
