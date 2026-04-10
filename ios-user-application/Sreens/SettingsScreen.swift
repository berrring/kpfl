//
//  SettingsScreen.swift
//  KPFL
//
//  Created by Codex on 9/4/26.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var settings: AppSettings

    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Settings", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 12) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Appearance")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))

                            Picker("Theme", selection: $settings.themeMode) {
                                ForEach(AppSettings.ThemeMode.allCases) { mode in
                                    Text(mode.title).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text("Choose app theme mode.")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))
                            Text("KPFL iOS App")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                            Text("Version 1.0.0")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
    }
}
