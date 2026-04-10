//
//  ClubProfileScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct ClubProfileScreen: View {
    @EnvironmentObject private var store: DataStore
    let clubId: String
    let onBack: () -> Void
    let onPlayer: (String) -> Void
    let onMatch: (String) -> Void

    @State private var tab: Tab = .overview
    enum Tab: String, CaseIterable { case overview = "Overview", squad = "Squad", matches = "Matches" }

    private var club: Club? { store.club(clubId) }
    private var players: [Player] { store.clubPlayers(clubId) }
    private var standing: Standing? { store.standings.first { $0.clubId == clubId } }
    private var position: Int { (store.standings.firstIndex { $0.clubId == clubId } ?? 0) + 1 }

    private var clubMatches: [Match] {
        store.matches
            .filter { $0.homeClubId == clubId || $0.awayClubId == clubId }
            .sorted { $0.dateISO > $1.dateISO }
    }

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: club?.shortName ?? "Club", showBack: true, onBack: onBack)

            switch store.loadState {
            case .idle, .loading:
                ProgressView().padding(.top, 30)
                Spacer()

            case .failed(let message):
                VStack(spacing: 10) {
                    Text("Failed to load club")
                        .font(.system(size: 14, weight: .black))
                    Text(message)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                    Button {
                        Task { await store.refreshAll() }
                    } label: {
                        Text("Try again")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12).padding(.vertical, 10)
                            .background(Color(hex: "#0A1628"))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 30)
                Spacer()

            case .loaded:
                if let club {
                    hero(club)

                    ScrollView {
                        VStack(spacing: 14) {
                            tabBar

                            switch tab {
                            case .overview: overview(club)
                            case .squad: squad
                            case .matches: matches
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 24)
                    }
                    .background(Color.appBackground)
                } else {
                    Spacer()
                    Text("Club not found").foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .background(Color.appBackground)
        .ignoresSafeArea(edges: .top)
        .task { await store.loadAllIfNeeded() }
        .refreshable { await store.refreshAll() }
    }

    private func hero(_ club: Club) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: club.primaryColorHex), Color(hex: club.primaryColorHex).opacity(0.75)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    ClubBadge(club: club, size: 64, ring: true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(club.name)
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.white)
                        Text("\(club.city), Kyrgyzstan")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                }
            }
            .padding(14)
        }
        .frame(height: 150)
    }

    private var tabBar: some View {
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

    private func overview(_ club: Club) -> some View {
        VStack(spacing: 14) {
            KPCard {
                HStack(spacing: 10) {
                    statBox(title: "Position", value: "#\(position)", accent: .black)
                    statBox(title: "Points", value: "\(standing?.points ?? 0)", accent: Color(hex: "#E8A912"))
                    statBox(title: "Matches", value: "\(standing?.played ?? 0)", accent: .black)
                    let gd = (standing?.goalsFor ?? 0) - (standing?.goalsAgainst ?? 0)
                    statBox(title: "Goal Diff", value: "\(gd >= 0 ? "+" : "")\(gd)", accent: gd >= 0 ? .green : .red)
                }
            }

            KPCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Club Information")
                        .font(.system(size: 14, weight: .black))
                    infoRow(icon: "sportscourt", title: "Stadium", value: club.stadium)
                    infoRow(icon: "person.2.fill", title: "Capacity", value: "\(club.capacity)")
                    infoRow(icon: "calendar", title: "Founded", value: "\(club.founded)")
                    infoRow(icon: "mappin.and.ellipse", title: "City", value: club.city)
                }
            }

            if let form = standing?.form, !form.isEmpty {
                KPCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Form")
                            .font(.system(size: 14, weight: .black))
                        HStack(spacing: 8) {
                            ForEach(Array(form.enumerated()), id: \.offset) { _, f in
                                Text(f)
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(f == "W" ? .green : (f == "D" ? .gray : .red))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                }
            }

            if let coach = players.first(where: { $0.isCoach }) {
                KPCard {
                    HStack(spacing: 12) {
                        Circle().fill(Color.black.opacity(0.06)).frame(width: 52, height: 52)
                            .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(coach.firstName) \(coach.lastName)")
                                .font(.system(size: 13, weight: .black))
                            Text("Head Coach")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var squad: some View {
        let regular = players.filter { !$0.isCoach }
        let gk = regular.filter { $0.position == .GK }
        let df = regular.filter { $0.position == .DF }
        let mf = regular.filter { $0.position == .MF }
        let fw = regular.filter { $0.position == .FW }

        let groups: [(title: String, color: Color, list: [Player])] = [
            ("Goalkeepers", .yellow, gk),
            ("Defenders", .blue, df),
            ("Midfielders", .green, mf),
            ("Forwards", .red, fw)
        ]

        return VStack(spacing: 12) {
            ForEach(groups, id: \.title) { g in
                KPCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("\(g.title) (\(g.list.count))")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(g.color)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            Spacer()
                        }

                        VStack(spacing: 8) {
                            ForEach(g.list, id: \.id) { p in
                                Button { onPlayer(p.id) } label: {
                                    HStack(spacing: 10) {
                                        Text("\(p.number)")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(.white)
                                            .frame(width: 34, height: 34)
                                            .background(Color(hex: "#0A1628"))
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(p.firstName) \(p.lastName)")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(.black)
                                            Text(p.nationality)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.gray.opacity(0.6))
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

    private var matches: some View {
        VStack(spacing: 10) {
            ForEach(clubMatches.prefix(10), id: \.id) { m in
                MatchCardView(match: m, onTap: { onMatch(m.id) })
            }
        }
    }

    private func statBox(title: String, value: String, accent: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(accent)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(.gray)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 10, weight: .bold)).foregroundStyle(.gray)
                Text(value).font(.system(size: 13, weight: .semibold)).foregroundStyle(.black)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
