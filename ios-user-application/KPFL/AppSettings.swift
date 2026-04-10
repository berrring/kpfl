//
//  AppSettings.swift
//  KPFL
//
//  Created by Codex on 9/4/26.
//

import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    enum ThemeMode: String, CaseIterable, Identifiable {
        case system
        case light
        case dark

        var id: String { rawValue }

        var title: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }

    @Published var themeMode: ThemeMode {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: Self.themeModeKey)
        }
    }

    static let themeModeKey = "kpfl.settings.themeMode"

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.themeModeKey) ?? ThemeMode.system.rawValue
        self.themeMode = ThemeMode(rawValue: raw) ?? .system
    }

    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
