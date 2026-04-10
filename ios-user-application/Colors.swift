//
//  Colors.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var hexClean = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexClean.hasPrefix("#") { hexClean.removeFirst() }
        if hexClean.count == 3 {
            hexClean = hexClean.map { "\($0)\($0)" }.joined()
        }
        var rgb: UInt64 = 0
        Scanner(string: hexClean).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    static var appBackground: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0)
            : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        })
    }
}

struct KPCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(14)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

struct MobileHeader: View {
    let title: String
    var showBack: Bool = false
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            if showBack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(
            Color(UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 0.03, green: 0.04, blue: 0.06, alpha: 1.0)
                }
                return UIColor(red: 0.04, green: 0.09, blue: 0.16, alpha: 1.0)
            })
        )
    }
}
