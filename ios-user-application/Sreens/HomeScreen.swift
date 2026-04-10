//
//  HomeScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var store: DataStore

    let onOpenMatches: () -> Void
    let onOpenStandings: () -> Void
    let onOpenClubs: () -> Void
    let onOpenNews: () -> Void
    let onOpenStats: () -> Void
    let onMatch: (String) -> Void
    let onClub: (String) -> Void
    let onNews: (String) -> Void

    private var liveMatches: [Match] { store.matches.filter { $0.status == .live } }
    private var upcoming: [Match] { store.matches.filter { $0.status == .scheduled }.sorted { $0.dateISO < $1.dateISO } }
    private var latestResults: [Match] { store.matches.filter { $0.status == .final }.sorted { $0.dateISO > $1.dateISO } }
    private var topStandings: [Standing] { store.standings.sorted { $0.points > $1.points } }
    private var latestNews: [NewsItem] { store.news.sorted { $0.dateISO > $1.dateISO } }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                MobileHeader(title: "KPFL")

                switch store.loadState {
                case .idle, .loading:
                    loadingBlock

                case .failed(let message):
                    errorBlock(message)

                case .loaded:
                    heroBlock

                    VStack(spacing: 14) {
                        upcomingBlock
                        resultsBlock
                        newsBlock
                        tableBlock
                        topScorersBlock
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 90)
                }
            }
            .background(Color.appBackground)
        }
        .scrollIndicators(.hidden)
        .task {
            await store.loadAllIfNeeded()
        }
        .refreshable {
            await store.refreshAll()
        }
    }

    private var loadingBlock: some View {
        VStack(spacing: 12) {
            heroSkeleton
            KPCard { HStack { ProgressView(); Spacer(); Text("Loading…").foregroundStyle(.gray) } }
                .padding(.horizontal, 14)
            Spacer(minLength: 40)
        }
        .padding(.top, 6)
    }

    private func errorBlock(_ message: String) -> some View {
        VStack(spacing: 12) {
            heroSkeleton
            KPCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Failed to load")
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
            }
            .padding(.horizontal, 14)
            Spacer(minLength: 40)
        }
    }

    private var heroSkeleton: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#0A1628"), Color(hex: "#0A1628").opacity(0.95)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 10) {
                Text("KPFL 2026")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.white)
                Text("Loading matches…")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 260)
        .overlay(
            Rectangle()
                .fill(LinearGradient(colors: [.clear, Color(hex: "#E8A912").opacity(0.22), .clear],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var heroBlock: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#0A1628"), Color(hex: "#0A1628").opacity(0.95)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 12) {
                if let live = liveMatches.first {
                    HStack(spacing: 8) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                            .shadow(color: .red.opacity(0.5), radius: 8)
                        Text("LIVE NOW")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(Color.red.opacity(0.9))
                        Spacer()
                        Text("Round \(live.round)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    HeroMatchCard(match: live, onTap: { onMatch(live.id) })
                } else if let up = upcoming.first {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Featured Match")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                            Text("KPFL 2026")
                                .font(.system(size: 24, weight: .black))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Button { onOpenMatches() } label: {
                            HStack(spacing: 6) {
                                Text("Full Schedule")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: "#E8A912"))
                        }
                        .buttonStyle(.plain)
                    }
                    HeroMatchCard(match: up, onTap: { onMatch(up.id) })
                } else {
                    Text("No matches available")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .frame(height: 260)
        .overlay(
            Rectangle()
                .fill(LinearGradient(colors: [.clear, Color(hex: "#E8A912").opacity(0.22), .clear],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var upcomingBlock: some View {
        KPCard {
            HStack {
                Text("Upcoming Matches")
                    .font(.system(size: 14, weight: .black))
                Spacer()
                Button("View All") { onOpenMatches() }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "#E8A912"))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Array(upcoming.prefix(4).enumerated()), id: \.offset) { _, m in
                    MatchCardView(match: m, onTap: { onMatch(m.id) })
                }
            }
        }
    }

    private var resultsBlock: some View {
        KPCard {
            HStack {
                Text("Latest Results")
                    .font(.system(size: 14, weight: .black))
                Spacer()
                Button("View All") { onOpenMatches() }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "#E8A912"))
            }

            VStack(spacing: 10) {
                ForEach(latestResults.prefix(5), id: \.id) { m in
                    CompactMatchRow(match: m, onTap: { onMatch(m.id) })
                }
            }
        }
    }

    private var newsBlock: some View {
        KPCard {
            HStack {
                Text("Latest News")
                    .font(.system(size: 14, weight: .black))
                Spacer()
                Button("View All") { onOpenNews() }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "#E8A912"))
            }

            if let first = latestNews.first {
                NewsHeroCard(item: first, onTap: { onNews(first.id) })
                    .padding(.bottom, 8)
            }

            VStack(spacing: 10) {
                ForEach(latestNews.dropFirst().prefix(3), id: \.id) { n in
                    NewsCompactRow(item: n, onTap: { onNews(n.id) })
                }
            }
        }
    }

    private var tableBlock: some View {
        KPCard {
            HStack {
                Text("League Table")
                    .font(.system(size: 14, weight: .black))
                Spacer()
                Button("Full") { onOpenStandings() }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "#E8A912"))
            }

            VStack(spacing: 10) {
                ForEach(Array(topStandings.prefix(6).enumerated()), id: \.offset) { (idx, s) in
                    if let club = store.club(s.clubId) {
                        Button {
                            onClub(club.id)
                        } label: {
                            HStack(spacing: 10) {
                                rankPill(idx + 1)
                                ClubBadge(club: club, size: 26)
                                Text(club.shortName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.black)
                                Spacer()
                                Text("\(s.played)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.gray)
                                    .frame(width: 22)
                                Text("\(s.points)")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(.black)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var topScorersBlock: some View {
        KPCard {
            HStack {
                Text("Top Scorers")
                    .font(.system(size: 14, weight: .black))
                Spacer()
                Button("All Stats") { onOpenStats() }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "#E8A912"))
            }

            if store.topScorersHistory.isEmpty {
                Text("No data available")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.gray)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(store.topScorersHistory.prefix(5), id: \.id) { e in
                        HStack(spacing: 10) {
                            rankPill(e.rankNo)
                            numberBall(e.rankNo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(e.playerName)
                                    .font(.system(size: 13, weight: .semibold))
                                if let position = e.positionName, !position.isEmpty {
                                    Text(position)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.gray)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(e.goals)")
                                    .font(.system(size: 18, weight: .black))
                                Text("GOALS")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
        }
    }

    private func rankPill(_ n: Int) -> some View {
        Text("\(n)")
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(n == 1 ? Color(hex: "#0A1628") : (n <= 3 ? .white : .gray))
            .frame(width: 24, height: 24)
            .background(
                Group {
                    if n == 1 {
                        LinearGradient(colors: [Color(hex: "#F5C742"), Color(hex: "#E8A912")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else if n <= 3 {
                        Color(hex: "#0A1628")
                    } else {
                        Color.appBackground
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func numberBall(_ number: Int) -> some View {
        Text("\(number)")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(Color(hex: "#0A1628"))
            .clipShape(Circle())
    }
}
