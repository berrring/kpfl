//
//  MatchDetailsScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct MatchDetailsScreen: View {
    @EnvironmentObject private var store: DataStore
    let matchId: String
    let onBack: () -> Void
    let onPlayer: (String) -> Void
    let onClub: (String) -> Void

    private var match: Match? { store.matches.first { $0.id == matchId } }

    var body: some View {
        if let match, let home = store.club(match.homeClubId), let away = store.club(match.awayClubId) {
            VStack(spacing: 0) {
                MobileHeader(title: "Match", showBack: true, onBack: onBack)

                header(match: match, home: home, away: away)

                ScrollView {
                    VStack(spacing: 14) {
                        if (match.status == .live || match.status == .final) {
                            eventsCard(match: match, home: home, away: away)
                            summaryCard(match: match, home: home, away: away)
                        } else {
                            KPCard {
                                VStack(spacing: 10) {
                                    Text("⏳").font(.system(size: 34))
                                    Text("Match hasn't started")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Kick-off at \(match.time) on \(DateFmt.full(match.dateISO))")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 24)
                }
                .background(Color.appBackground)
            }
            .ignoresSafeArea(edges: .top)
        } else {
            VStack {
                MobileHeader(title: "Match", showBack: true, onBack: onBack)
                Spacer()
                Text("Match not found").foregroundStyle(.gray)
                Spacer()
            }
            .background(Color.appBackground)
        }
    }

    private func header(match: Match, home: Club, away: Club) -> some View {
        ZStack {
            Color(hex: "#0A1628")
            VStack(spacing: 12) {
                HStack {
                    statusPill(match)
                    Spacer()
                    Text("Round \(match.round)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }

                HStack {
                    Button { onClub(home.id) } label: {
                        VStack(spacing: 8) {
                            ClubBadge(club: home, size: 52, ring: true)
                            Text(home.name)
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text(home.city)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .frame(maxWidth: .infinity)
                    }.buttonStyle(.plain)

                    if match.status == .scheduled {
                        VStack(spacing: 4) {
                            Text(match.time)
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(Color(hex: "#E8A912"))
                            Text("Kick-off")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(width: 120)
                    } else {
                        HStack(spacing: 10) {
                            Text("\(match.homeScore)")
                                .font(.system(size: 44, weight: .black))
                                .foregroundStyle(.white)
                            Text("-")
                                .font(.system(size: 24, weight: .black))
                                .foregroundStyle(.white.opacity(0.6))
                            Text("\(match.awayScore)")
                                .font(.system(size: 44, weight: .black))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 140)
                    }

                    Button { onClub(away.id) } label: {
                        VStack(spacing: 8) {
                            ClubBadge(club: away, size: 52, ring: true)
                            Text(away.name)
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text(away.city)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .frame(maxWidth: .infinity)
                    }.buttonStyle(.plain)
                }

                HStack(spacing: 16) {
                    infoPill(icon: "calendar", text: DateFmt.full(match.dateISO))
                    infoPill(icon: "mappin.and.ellipse", text: match.stadium)
                    if let a = match.attendance {
                        infoPill(icon: "person.2.fill", text: "\(a) fans")
                    }
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
                .lineLimit(1)
            }
            .padding(14)
        }
        .overlay(
            Rectangle()
                .fill(LinearGradient(colors: [.clear, Color(hex: "#E8A912").opacity(0.25), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func statusPill(_ match: Match) -> some View {
        Group {
            switch match.status {
            case .live:
                HStack(spacing: 6) {
                    Circle().fill(.red).frame(width: 6, height: 6)
                    Text("\(match.minute ?? 0)'")
                        .font(.system(size: 12, weight: .black))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            case .final:
                Text("Full Time")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            case .scheduled:
                Text("Scheduled")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
    }

    private func eventsCard(match: Match, home: Club, away: Club) -> some View {
        let events = store.matchEvents(match.id).sorted { $0.minute < $1.minute }
        return Group {
            if !events.isEmpty {
                KPCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Match Events")
                            .font(.system(size: 14, weight: .black))

                        Divider().opacity(0.2)

                        VStack(spacing: 10) {
                            ForEach(events, id: \.id) { e in
                                Button {
                                    onPlayer(e.playerId)
                                } label: {
                                    HStack(spacing: 10) {
                                        if e.clubId == home.id {
                                            eventSide(event: e, alignRight: false)
                                        } else {
                                            Spacer()
                                            eventSide(event: e, alignRight: true)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private func eventSide(event: MatchEvent, alignRight: Bool) -> some View {
        let p = store.player(event.playerId)
        let a = event.assistPlayerId.flatMap { store.player($0) }
        let icon: String = (event.type == .GOAL ? "⚽" : (event.type == .YELLOW ? "🟨" : "🟥"))

        return HStack(spacing: 10) {
            if !alignRight {
                eventBox(icon: icon, minute: event.minute)
            }
            VStack(alignment: alignRight ? .trailing : .leading, spacing: 2) {
                Text(p != nil ? "\(p!.firstName) \(p!.lastName)" : "Unknown")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black)

                if let a, event.type == .GOAL {
                    Text("Assist: \(a.firstName.prefix(1)). \(a.lastName)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.gray)
                }
            }
            if alignRight {
                eventBox(icon: icon, minute: event.minute)
            }
        }
    }

    private func eventBox(icon: String, minute: Int) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.system(size: 18))
            Text("\(minute)'")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(.gray)
        }
        .frame(width: 48, height: 48)
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func summaryCard(match: Match, home: Club, away: Club) -> some View {
        let events = store.matchEvents(match.id)
        let homeGoals = events.filter { $0.type == .GOAL && $0.clubId == home.id }.count
        let awayGoals = events.filter { $0.type == .GOAL && $0.clubId == away.id }.count
        let yellows = events.filter { $0.type == .YELLOW }.count
        return KPCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Match Summary")
                    .font(.system(size: 14, weight: .black))
                HStack {
                    summaryStat(value: "\(homeGoals)", label: "Home Goals")
                    Divider().frame(height: 36).opacity(0.2)
                    summaryStat(value: "\(yellows)", label: "Yellow Cards", accent: .orange)
                    Divider().frame(height: 36).opacity(0.2)
                    summaryStat(value: "\(awayGoals)", label: "Away Goals")
                }
            }
        }
    }

    private func summaryStat(value: String, label: String, accent: Color? = nil) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(accent ?? .black)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
