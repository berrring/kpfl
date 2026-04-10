//
//  MyTeamViewModel.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

@MainActor
final class MyTeamViewModel: ObservableObject {
    @Published private(set) var team: FantasyTeam? = nil

    private let store = FantasyTeamStore()
    private let api = KPFLAPI.shared

    var teamName: String { team?.name ?? "" }
    var budgetLeft: Double { team?.budget ?? 100.0 }
    var totalPoints: Int { team?.totalPoints ?? 0 }

    func load() {
        team = store.loadTeam().map { normalizeTeam($0) }
        Task { await refreshFromBackendIfAvailable() }
    }

    func players(for position: String) -> [FantasyPlayer] {
        team?.players.filter { $0.position == position } ?? []
    }

    private func normalizeTeam(_ team: FantasyTeam) -> FantasyTeam {
        var updated = team
        var seen = Set<Int>()
        updated.players = updated.players.filter { seen.insert($0.id).inserted }
        updated.totalPoints = updated.players.reduce(0) { $0 + $1.totalPoints }
        return updated
    }

    private func refreshFromBackendIfAvailable() async {
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
            // Keep local state as fallback.
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
