//
//  FantasyHomeViewModel.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

@MainActor
final class FantasyHomeViewModel: ObservableObject {
    @Published private(set) var team: FantasyTeam? = nil
    @Published private(set) var seasonLabel: String = "Season"
    @Published private(set) var gameweekLabel: String = "Gameweek 1"

    private let store = FantasyTeamStore()
    private let api = KPFLAPI.shared

    var hasTeam: Bool { team != nil }

    func load() {
        team = store.loadTeam().map { normalizeTeam($0) }
        Task { await refreshFromBackend() }
    }

    func totalPointsText() -> String {
        let points = team?.totalPoints ?? 0
        return "\(points)"
    }

    func gameweekPointsText() -> String {
        let points = min(team?.totalPoints ?? 0, 48)
        return "\(points)"
    }

    private func normalizeTeam(_ team: FantasyTeam) -> FantasyTeam {
        var updated = team
        updated.totalPoints = updated.players.reduce(0) { $0 + $1.totalPoints }
        return updated
    }

    private func refreshFromBackend() async {
        do {
            let round = try await api.fantasyCurrentRound()
            if let seasonYear = round.seasonYear {
                seasonLabel = "Season \(seasonYear)"
            }
            gameweekLabel = "Gameweek \(round.roundNumber)"
        } catch {
            // Keep defaults if current round isn't available.
        }

        guard UserDefaults.standard.string(forKey: KPFLAPI.authTokenKey) != nil else { return }
        do {
            let overview = try await api.fantasyMyTeam()
            let squad = try await api.fantasyMySquad()
            let players = squad.players.map {
                FantasyPlayer(
                    id: Int($0.playerId),
                    name: "\($0.firstName) \($0.lastName)",
                    club: $0.clubName ?? "Unknown",
                    position: mapPosition($0.position),
                    price: $0.currentPrice ?? $0.acquiredPrice ?? 5.0,
                    totalPoints: 0
                )
            }
            let remote = FantasyTeam(
                id: team?.id ?? UUID(),
                name: overview.teamName,
                players: players,
                budget: overview.currentBudget,
                totalPoints: overview.totalPoints,
                remoteTeamId: overview.teamId,
                seasonYear: overview.seasonYear
            )
            team = normalizeTeam(remote)
            store.saveTeam(remote)
        } catch {
            // No team on backend yet or unauthorized.
        }
    }

    private func mapPosition(_ raw: String) -> String {
        switch raw.uppercased() {
        case "GK": return "GK"
        case "DF", "DEF": return "DEF"
        case "MF", "MID": return "MID"
        case "FW", "FWD": return "FWD"
        default: return "MID"
        }
    }
}
