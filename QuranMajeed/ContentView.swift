//
//  ContentView.swift
//  QuranMajeed
//
//  Created by Elsehrawy on 07/03/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        QuranPageView()
    }
}

#Preview {
    ContentView()
        .environmentObject(QuranDataService())
}
