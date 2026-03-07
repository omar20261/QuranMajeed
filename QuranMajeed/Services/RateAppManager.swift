//
//  RateAppManager.swift
//  QuranMajeed
//

import Foundation
import StoreKit
import SwiftUI
import Combine

class RateAppManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let lastRatingPromptDateKey = "lastRatingPromptDate"
    private let hasRatedAppKey = "hasRatedApp"
    private let appLaunchTimeKey = "appLaunchTime"
    private let daysBetweenPrompts = 1
    private let delayAfterLaunch: TimeInterval = 3.0

    @Published var shouldShowRatingPrompt = false

    func setAppLaunchTime() {
        userDefaults.set(Date(), forKey: appLaunchTimeKey)
    }

    func checkShouldShowRatingPromptAfterDelay() {
        guard !hasUserRatedApp() else { return }

        guard let launchTime = userDefaults.object(forKey: appLaunchTimeKey) as? Date else { return }
        let timeSinceLaunch = Date().timeIntervalSince(launchTime)
        guard timeSinceLaunch >= delayAfterLaunch else { return }

        let lastPromptDate = userDefaults.object(forKey: lastRatingPromptDateKey) as? Date
        let currentDate = Date()

        if let lastDate = lastPromptDate {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastDate, to: currentDate).day ?? 0
            if daysSinceLastPrompt >= daysBetweenPrompts {
                shouldShowRatingPrompt = true
            }
        } else {
            shouldShowRatingPrompt = true
        }
    }

    func showRatingPrompt() {
        userDefaults.set(Date(), forKey: lastRatingPromptDateKey)
        shouldShowRatingPrompt = false

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func markAsRated() {
        userDefaults.set(true, forKey: hasRatedAppKey)
        shouldShowRatingPrompt = false
    }

    func dismissPrompt() {
        userDefaults.set(Date(), forKey: lastRatingPromptDateKey)
        shouldShowRatingPrompt = false
    }

    private func hasUserRatedApp() -> Bool {
        return userDefaults.bool(forKey: hasRatedAppKey)
    }
}
