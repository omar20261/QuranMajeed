//
//  ControlToolbar.swift
//  QuranMajeed
//

import SwiftUI

struct ControlToolbar: View {
    let currentPage: Int
    let totalPages: Int
    let juz: Int
    let onSurahListTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onSurahListTap) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(QuranTheme.goldDark)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Page \(currentPage) of \(totalPages)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(QuranTheme.arabicText)
                Text("Juz \(juz)")
                    .font(.caption)
                    .foregroundStyle(QuranTheme.secondaryText)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "bookmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(QuranTheme.goldDark)
                    .frame(width: 44, height: 44)
            }
            .disabled(true)
            .opacity(0.4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            QuranTheme.pageBackground
                .shadow(color: QuranTheme.goldDark.opacity(0.15), radius: 8, y: -4)
        )
        .overlay(
            Rectangle()
                .fill(QuranTheme.pageBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    VStack {
        Spacer()
        ControlToolbar(
            currentPage: 1,
            totalPages: 604,
            juz: 1,
            onSurahListTap: {}
        )
    }
    .background(QuranTheme.pageBackground)
}
