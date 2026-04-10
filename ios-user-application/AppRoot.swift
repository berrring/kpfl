//
//  AppRoot.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

enum TabRoute: String {
    case home, matches, standings, fantasy, clubs, more
}

enum Screen: Hashable {
    case auth
    case news
    case newsDetail(String)
    case stats
    case fantasy
    case fantasyCreateTeam
    case fantasyMyTeam
    case fantasyPlayerSelection
    case fantasyLeague
    case fantasyJoinLeague
    case fantasyCreateLeague
    case fantasyGameweek
    case settings
    case matchDetail(String)
    case clubProfile(String)
    case playerProfile(String)
}

struct AppRoot: View {
    @EnvironmentObject private var store: DataStore
    @State private var tab: TabRoute = .home
    @State private var stack: [Screen] = []

    var body: some View {
        NavigationStack(path: $stack) {
            ZStack(alignment: .bottom) {
                tabContent
                BottomBar(selected: $tab)
            }
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: Screen.self, destination: destinationView)
            .task {
                await store.loadAllIfNeeded()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .home:
            HomeScreen(
                onOpenMatches: { tab = .matches },
                onOpenStandings: { tab = .standings },
                onOpenClubs: { tab = .clubs },
                onOpenNews: { stack.append(.news) },
                onOpenStats: { stack.append(.stats) },
                onMatch: { id in stack.append(.matchDetail(id)) },
                onClub: { id in stack.append(.clubProfile(id)) },
                onNews: { id in stack.append(.newsDetail(id)) }
            )

        case .matches:
            MatchesScreen(onMatch: { id in stack.append(.matchDetail(id)) })

        case .standings:
            StandingsScreen(onClub: { id in stack.append(.clubProfile(id)) })

        case .fantasy:
            FantasyScreen(
                showBack: false,
                onBack: { },
                onManageTeam: { stack.append(.fantasyMyTeam) },
                onCreateTeam: { stack.append(.fantasyCreateTeam) },
                onJoinLeague: { stack.append(.fantasyJoinLeague) },
                onCreateLeague: { stack.append(.fantasyCreateLeague) },
                onOpenGameweek: { stack.append(.fantasyGameweek) }
            )

        case .clubs:
            ClubsScreen(onClub: { id in stack.append(.clubProfile(id)) })

        case .more:
            MoreScreen(
                onNews: { stack.append(.news) },
                onFantasy: { stack.append(.fantasy) },
                onSettings: { stack.append(.settings) },
                onAuth: { stack.append(.auth) }
            )
        }
    }

    @ViewBuilder
    private func destinationView(_ screen: Screen) -> some View {
        switch screen {
        case .auth:
            AuthScreen(
                onBack: { pop() },
                onSignedIn: { pop() }
            )

        case .news:
            NewsScreen(
                onBack: { pop() },
                onSelect: { id in stack.append(.newsDetail(id)) }
            )

        case .newsDetail(let id):
            NewsDetailScreen(newsId: id, onBack: { pop() })

        case .stats:
            StatsScreen(
                onBack: { pop() },
                onPlayer: { id in stack.append(.playerProfile(id)) },
                onClub: { id in stack.append(.clubProfile(id)) }
            )

        case .fantasy:
            FantasyScreen(
                showBack: true,
                onBack: { pop() },
                onManageTeam: { stack.append(.fantasyMyTeam) },
                onCreateTeam: { stack.append(.fantasyCreateTeam) },
                onJoinLeague: { stack.append(.fantasyJoinLeague) },
                onCreateLeague: { stack.append(.fantasyCreateLeague) },
                onOpenGameweek: { stack.append(.fantasyGameweek) }
            )

        case .fantasyCreateTeam:
            CreateTeamView(onBack: { pop() }, onCreated: {
                pop()
                stack.append(.fantasyMyTeam)
            })

        case .fantasyMyTeam:
            MyTeamView(onBack: { pop() }, onAddPlayer: { stack.append(.fantasyPlayerSelection) })

        case .fantasyPlayerSelection:
            PlayersSelectionView(onBack: { pop() }, onPlayerAdded: { pop() })

        case .fantasyLeague:
            FantasyLeagueView(onBack: { pop() })

        case .fantasyJoinLeague:
            JoinLeagueView(onBack: { pop() }, onDone: {
                pop()
                stack.append(.fantasyLeague)
            })

        case .fantasyCreateLeague:
            CreateLeagueView(onBack: { pop() }, onDone: {
                pop()
                stack.append(.fantasyLeague)
            })

        case .fantasyGameweek:
            GameweekView(onBack: { pop() })

        case .settings:
            SettingsScreen(onBack: { pop() })

        case .matchDetail(let id):
            MatchDetailsScreen(
                matchId: id,
                onBack: { pop() },
                onPlayer: { pid in stack.append(.playerProfile(pid)) },
                onClub: { cid in stack.append(.clubProfile(cid)) }
            )

        case .clubProfile(let id):
            ClubProfileScreen(
                clubId: id,
                onBack: { pop() },
                onPlayer: { pid in stack.append(.playerProfile(pid)) },
                onMatch: { mid in stack.append(.matchDetail(mid)) }
            )

        case .playerProfile(let id):
            PlayerProfileScreen(
                playerId: id,
                onBack: { pop() },
                onClub: { cid in stack.append(.clubProfile(cid)) }
            )
        }
    }

    private func pop() {
        if !stack.isEmpty { stack.removeLast() }
    }
}

struct BottomBar: View {
    @Binding var selected: TabRoute

    var body: some View {
        HStack {
            barItem(.home, "Home", "house.fill")
            barItem(.matches, "Schedule", "calendar")
            barItem(.standings, "Table", "list.number")
            barItem(.fantasy, "Fantasy", "sportscourt")
            barItem(.clubs, "Clubs", "shield.fill")
            barItem(.more, "More", "ellipsis")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.black.opacity(0.06)), alignment: .top)
    }

    private func barItem(_ tab: TabRoute, _ title: String, _ icon: String) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selected == tab ? Color(hex: "#0A1628") : Color.gray)
        }
    }
}
