//
//  CommonViews.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct ClubBadge: View {
    let club: Club
    var size: CGFloat = 36
    var ring: Bool = false

    var body: some View {
        ZStack {
            Circle().fill(Color(hex: club.primaryColorHex))
            Text(String(club.shortName.prefix(3)))
                .font(.system(size: size * 0.28, weight: .black))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle().stroke(.white.opacity(ring ? 0.8 : 0), lineWidth: ring ? 3 : 0)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
    }
}

struct TagBadge: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

enum DateFmt {
    static func short(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        guard let d = f.date(from: iso) else { return iso }
        let out = DateFormatter()
        out.dateFormat = "dd MMM"
        return out.string(from: d)
    }

    static func full(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        guard let d = f.date(from: iso) else { return iso }
        let out = DateFormatter()
        out.dateFormat = "EEEE, dd MMM yyyy"
        return out.string(from: d)
    }

    static func age(birthISO: String) -> Int {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        guard let bd = f.date(from: birthISO) else { return 0 }
        let cal = Calendar.current
        return cal.dateComponents([.year], from: bd, to: Date()).year ?? 0
    }
}

enum TagColor {
    static func color(_ tag: NewsTag) -> Color {
        switch tag {  
        case .Transfer: return .purple
        case .Matchday: return .green
        case .Club: return .blue
        case .League: return Color(hex: "#E8A912")
        case .Injury: return .red
        case .Interview: return .gray
        }
    }
}
