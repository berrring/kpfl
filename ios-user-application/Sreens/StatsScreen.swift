//
//  StatsScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct StatsScreen: View {
    @EnvironmentObject private var store: DataStore
    let onBack: () -> Void
    let onPlayer: (String) -> Void
    let onClub: (String) -> Void

    enum Tab: String, CaseIterable { case goals = "Goals", assists = "Assists", cards = "Cards", appearances = "Appearances", records = "Records" }
    @State private var tab: Tab = .goals

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Stats", showBack: true, onBack: onBack)
            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        HStack(spacing: 8) {
                            ForEach(Tab.allCases, id: \.self) { t in
                                Button {
                                    tab = t
                                } label: {
                                    Text(t.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(tab == t ? .white : .gray)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(tab == t ? Color(hex: "#0A1628") : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                    }

                    switch tab {
                    case .goals:
                        historyTopScorersList
                    case .assists:
                        statList(title: "Top Assists", items: topAssisters().map { (p: $0.player, a: $0.value, extra1: "", extra2: "") }, valueLabel: "ASSISTS") { p in
                            onPlayer(p.id)
                        }
                    case .cards:
                        cardsList
                    case .appearances:
                        topAppearancesList
                    case .records:
                        recordsList
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
    }

    private func statList(
        title: String,
        items: [(p: Player, a: Int, extra1: String, extra2: String)],
        valueLabel: String,
        onTap: @escaping (Player) -> Void
    ) -> some View {
        KPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color(hex: "#0A1628"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(spacing: 10) {
                    ForEach(Array(items.prefix(10).enumerated()), id: \.offset) { idx, item in
                        let club = store.club(item.p.clubId)
                        Button {
                            onTap(item.p)
                        } label: {
                            HStack(spacing: 10) {
                                rankBubble(idx + 1)
                                numberBall(item.p.number)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(item.p.firstName) \(item.p.lastName)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.black)
                                    if let club {
                                        Button {
                                            onClub(club.id)
                                        } label: {
                                            HStack(spacing: 6) {
                                                ClubBadge(club: club, size: 18)
                                                Text(club.name)
                                                    .font(.system(size: 11, weight: .semibold))
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(item.a)")
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundStyle(.black)
                                    Text(valueLabel)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Divider().opacity(0.12)
                    }
                }
            }
        }
    }

    private var cardsList: some View {
        let items = mostCards()
        return KPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Disciplinary")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color(hex: "#0A1628"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(spacing: 10) {
                    ForEach(Array(items.prefix(10).enumerated()), id: \.offset) { idx, item in
                        let club = store.club(item.player.clubId)
                        Button { onPlayer(item.player.id) } label: {
                            HStack(spacing: 10) {
                                Text("\(idx+1)")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.gray)
                                    .frame(width: 28)
                                numberBall(item.player.number)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(item.player.firstName) \(item.player.lastName)")
                                        .font(.system(size: 13, weight: .semibold))
                                    if let club {
                                        HStack(spacing: 6) {
                                            ClubBadge(club: club, size: 18)
                                            Text(club.name)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                }
                                Spacer()
                                HStack(spacing: 14) {
                                    HStack(spacing: 6) { Text("🟨"); Text("\(item.yellows)").fontWeight(.black) }
                                    HStack(spacing: 6) { Text("🟥"); Text("\(item.reds)").fontWeight(.black) }
                                }
                                .font(.system(size: 13, weight: .semibold))
                            }
                        }
                        .buttonStyle(.plain)
                        Divider().opacity(0.12)
                    }
                }
            }
        }
    }

    private var historyTopScorersList: some View {
        KPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Top Scorers")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color(hex: "#0A1628"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if store.topScorersHistory.isEmpty {
                    Text("No data available")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.topScorersHistory.prefix(20), id: \.id) { item in
                            HStack(spacing: 10) {
                                rankBubble(item.rankNo)
                                numberBall(item.rankNo)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.playerName)
                                        .font(.system(size: 13, weight: .semibold))
                                    if let position = item.positionName, !position.isEmpty {
                                        Text(position)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.gray)
                                    }
                                    if let matches = item.matchesPlayed {
                                        Text("Matches: \(matches)")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(item.goals)")
                                        .font(.system(size: 18, weight: .black))
                                    Text("GOALS")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.gray)
                                }
                            }
                            Divider().opacity(0.12)
                        }
                    }
                }
            }
        }
    }

    private var topAppearancesList: some View {
        KPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Top Appearances")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color(hex: "#0A1628"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if store.topAppearancesHistory.isEmpty {
                    Text("No data available")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.topAppearancesHistory.prefix(20), id: \.id) { item in
                            HStack(spacing: 10) {
                                rankBubble(item.rankNo)
                                numberBall(item.rankNo)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.playerName)
                                        .font(.system(size: 13, weight: .semibold))
                                    if let position = item.positionName, !position.isEmpty {
                                        Text(position)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(item.matchesPlayed)")
                                        .font(.system(size: 18, weight: .black))
                                    Text("MATCHES")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.gray)
                                }
                            }
                            Divider().opacity(0.12)
                        }
                    }
                }
            }
        }
    }

    private var recordsList: some View {
        KPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("All-Time Records")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color(hex: "#0A1628"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if store.historyRecords.isEmpty {
                    Text("No data available")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.historyRecords, id: \.id) { item in
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.recordKey)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.gray)
                                    Text(item.recordValue)
                                        .font(.system(size: 14, weight: .black))
                                }
                                Spacer()
                                if let note = item.sourceNote, !note.isEmpty {
                                    Text(note)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.gray)
                                }
                            }
                            Divider().opacity(0.12)
                        }
                    }
                }
            }
        }
    }

    private func rankBubble(_ n: Int) -> some View {
        Text("\(n)")
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(n == 1 ? Color(hex: "#0A1628") : (n <= 3 ? .white : .gray))
            .frame(width: 28, height: 28)
            .background(
                Group {
                    if n == 1 {
                        LinearGradient(colors: [Color(hex: "#F5C742"), Color(hex: "#E8A912")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else if n <= 3 {
                        Color(hex: "#0A1628")
                    } else {
                        Color.appBackground
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func numberBall(_ number: Int) -> some View {
        Text("\(number)")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(.white)
            .frame(width: 34, height: 34)
            .background(Color(hex: "#0A1628"))
            .clipShape(Circle())
    }

    private func topScorers() -> [(player: Player, value: Int)] {
        store.players.filter { !$0.isCoach }.map { p in
            (p, store.events.filter { $0.type == .GOAL && $0.playerId == p.id }.count)
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }
    }


    private func topAssisters() -> [(player: Player, value: Int)] {
        store.players.filter { !$0.isCoach }.map { p in
            (p, store.events.filter { $0.assistPlayerId == p.id }.count)
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }
    }

    private func mostCards() -> [(player: Player, yellows: Int, reds: Int, total: Int)] {
        store.players.filter { !$0.isCoach }.map { p in
            let y = store.events.filter { $0.type == .YELLOW && $0.playerId == p.id }.count
            let r = store.events.filter { $0.type == .RED && $0.playerId == p.id }.count
            return (p, y, r, y + r*2)
        }
        .filter { $0.total > 0 }
        .sorted { $0.total > $1.total }
    }
}
