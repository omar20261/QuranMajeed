//
//  RatingPromptView.swift
//  QuranMajeed
//

import SwiftUI

struct RatingPromptView: View {
    let onRate: () -> Void
    let onDismiss: () -> Void
    let onMarkAsRated: () -> Void

    @State private var starScale: CGFloat = 0.5
    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .scaleEffect(starScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
                                  .delay(Double(index) * 0.1), value: starScale)
                }
            }

            VStack(spacing: 12) {
                Text("Enjoying Quran Majeed?")
                    .font(.title.weight(.bold))
                    .foregroundColor(.primary)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.8), value: showContent)

                Text("Your feedback helps us improve and serve the Ummah better. A 5-star review would mean the world to us!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(1.0), value: showContent)
                    .padding(.horizontal, 8)
            }

            VStack(spacing: 12) {
                Button(action: {
                    onRate()
                    onMarkAsRated()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Rate on App Store")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                QuranTheme.gold,
                                QuranTheme.goldDark
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: QuranTheme.gold.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2), value: showContent)

                Button("Maybe Later") {
                    onDismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.4), value: showContent)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 32)
        .scaleEffect(showContent ? 1 : 0.9)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                starScale = 1.0
                showContent = true
            }
        }
    }
}

#Preview {
    RatingPromptView(
        onRate: {},
        onDismiss: {},
        onMarkAsRated: {}
    )
}
