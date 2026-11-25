//
//  QuranMajeedApp.swift
//  QuranMajeed
//
//  Created by Elsehrawy on 07/03/2026.
//

import SwiftUI

@main
struct QuranMajeedApp: App {
    @StateObject private var dataService = QuranDataService()
    @StateObject private var audioService = QuranAudioService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataService)
                .environmentObject(audioService)
        }
    }
}
