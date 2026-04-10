//
//  FantasyComponents.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI
import Foundation

struct FantasyStatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.gray)
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color(hex: "#0A1628"))
            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.gray.opacity(0.8))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct FantasyPlayerCard: View {
    let player: FantasyPlayer

    var body: some View {
        KPCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color(hex: "#0A1628"))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color(hex: "#0A1628"))
                        Text("\(player.club) • \(player.position)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }

                HStack {
                    Text("$\(String(format: "%.1f", player.price))M")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "#0A1628"))
                    Spacer()
                    Text("Pts: \(player.totalPoints)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

struct FantasyEmptySlot: View {
    let title: String
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            KPCard {
                VStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "#0A1628"))
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 80)
            }
        }
        .buttonStyle(.plain)
    }
}
