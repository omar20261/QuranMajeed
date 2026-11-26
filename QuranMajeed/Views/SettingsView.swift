//
//  SettingsView.swift
//  QuranMajeed
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button(action: { themeManager.current = theme }) {
                            HStack(spacing: 14) {
                                themePreview(for: theme)
                                Text(theme.rawValue)
                                    .foregroundStyle(QuranTheme.arabicText)
                                Spacer()
                                if themeManager.current == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(QuranTheme.goldDark)
                                        .fontWeight(.semibold)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(QuranTheme.pageBackground)
                    }
                }
                .foregroundStyle(QuranTheme.secondaryText)

                Section("Font Size") {
                    HStack(spacing: 16) {
                        Button {
                            if themeManager.fontSize > ThemeManager.minFontSize {
                                themeManager.fontSize -= 2
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 34))
                                .foregroundStyle(themeManager.fontSize > ThemeManager.minFontSize ? QuranTheme.goldDark : QuranTheme.secondaryText.opacity(0.4))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text("بِسْمِ ٱللَّهِ")
                            .font(QuranTheme.arabicFont(size: themeManager.fontSize))
                            .foregroundStyle(QuranTheme.arabicText)

                        Spacer()

                        Button {
                            if themeManager.fontSize < ThemeManager.maxFontSize {
                                themeManager.fontSize += 2
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 34))
                                .foregroundStyle(themeManager.fontSize < ThemeManager.maxFontSize ? QuranTheme.goldDark : QuranTheme.secondaryText.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(QuranTheme.pageBackground)
                }
                .foregroundStyle(QuranTheme.secondaryText)

                Section("About") {
                    HStack {
                        Text("App Version")
                            .foregroundStyle(QuranTheme.arabicText)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                            .foregroundStyle(QuranTheme.secondaryText)
                    }
                    .listRowBackground(QuranTheme.pageBackground)
                }
                .foregroundStyle(QuranTheme.secondaryText)
            }
            .scrollContentBackground(.hidden)
            .background(QuranTheme.pageBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(QuranTheme.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(QuranTheme.current.toolbarColorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(QuranTheme.secondaryText)
                            .padding(10)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private func themePreview(for theme: AppTheme) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(theme.pageBackground)
            .frame(width: 36, height: 36)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(theme.pageBorder, lineWidth: 1.5)
            )
            .overlay(
                Text("ب")
                    .font(.system(size: 16))
                    .foregroundStyle(theme.arabicText)
            )
    }
}

#Preview {
    SettingsView()
}
