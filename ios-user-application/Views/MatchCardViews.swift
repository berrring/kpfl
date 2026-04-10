//
//  MatchCardViews.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct MatchCardView: View {
    @EnvironmentObject private var store: DataStore
    let match: Match
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            KPCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(DateFmt.short(match.dateISO))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.gray)
                        Spacer()
                        statusPill
                    }

                    HStack {
                        if let home = store.club(match.homeClubId),
                           let away = store.club(match.awayClubId) {
                            VStack(alignment: .leading, spacing: 10) {
                                teamRow(club: home, score: match.homeScore)
                                teamRow(club: away, score: match.awayScore)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var statusPill: some View {
        Group {
            switch match.status {
            case .live:
                HStack(spacing: 6) {
                    Circle().fill(.red).frame(width: 6, height: 6)
                    Text("\(match.minute ?? 0)'")
                        .font(.system(size: 11, weight: .black))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            case .final:
                Text("FT")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            case .scheduled:
                Text(match.time)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    private func teamRow(club: Club, score: Int) -> some View {
        HStack(spacing: 10) {
            ClubBadge(club: club, size: 22)
            Text(club.shortName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black)
            Spacer()
            if match.status == .scheduled {
                Text("")
            } else {
                Text("\(score)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.black)
            }
        }
    }
}

struct CompactMatchRow: View {
    @EnvironmentObject private var store: DataStore
    let match: Match
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DateFmt.short(match.dateISO))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                    Text("Round \(match.round)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.gray.opacity(0.8))
                }
                Spacer()

                if let home = store.club(match.homeClubId),
                   let away = store.club(match.awayClubId) {
                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            ClubBadge(club: home, size: 18)
                            Text(home.shortName).font(.system(size: 11, weight: .semibold))
                        }
                        Text("\(match.homeScore) - \(match.awayScore)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(Color(hex: "#0A1628"))
                        HStack(spacing: 6) {
                            Text(away.shortName).font(.system(size: 11, weight: .semibold))
                            ClubBadge(club: away, size: 18)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

struct HeroMatchCard: View {
    @EnvironmentObject private var store: DataStore
    let match: Match
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )

                VStack(spacing: 14) {
                    HStack {
                        Text(DateFmt.full(match.dateISO))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.65))
                        Spacer()
                        Text(match.stadium)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.65))
                            .lineLimit(1)
                    }

                    if let home = store.club(match.homeClubId),
                       let away = store.club(match.awayClubId) {
                        HStack {
                            VStack(spacing: 8) {
                                ClubBadge(club: home, size: 48, ring: true)
                                Text(home.shortName)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            if match.status == .scheduled {
                                VStack(spacing: 4) {
                                    Text(match.time)
                                        .font(.system(size: 26, weight: .black))
                                        .foregroundStyle(Color(hex: "#E8A912"))
                                    Text("Kick-off")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            } else {
                                HStack(spacing: 10) {
                                    Text("\(match.homeScore)")
                                        .font(.system(size: 38, weight: .black))
                                        .foregroundStyle(.white)
                                    Text("-")
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundStyle(.white.opacity(0.6))
                                    Text("\(match.awayScore)")
                                        .font(.system(size: 38, weight: .black))
                                        .foregroundStyle(.white)
                                }
                            }
                            Spacer()
                            VStack(spacing: 8) {
                                ClubBadge(club: away, size: 48, ring: true)
                                Text(away.shortName)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }
}
