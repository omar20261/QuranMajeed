//
//  AyahMarkerView.swift
//  QuranMajeed
//

import SwiftUI

struct AyahMarkerView: View {
    let number: Int

    private var arabicNumber: String {
        let arabicNumerals = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        return String(number).map { arabicNumerals[Int(String($0))!] }.joined()
    }

    var body: some View {
        Text(arabicNumber)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
            )
    }
}

#Preview {
    HStack(spacing: 20) {
        AyahMarkerView(number: 1)
        AyahMarkerView(number: 25)
        AyahMarkerView(number: 286)
    }
    .padding()
}
