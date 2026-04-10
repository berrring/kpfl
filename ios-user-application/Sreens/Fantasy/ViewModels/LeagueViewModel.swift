//
//  LeagueViewModel.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

@MainActor
final class LeagueViewModel: ObservableObject {
    @Published private(set) var entries: [FantasyLeagueEntry] = []
    @Published private(set) var isLoading = false
    @Published var message: String?
    private let api = KPFLAPI.shared

    func load() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let leaderboard = try await api.fantasyLeaderboard()
                entries = leaderboard.enumerated().map { idx, item in
                    FantasyLeagueEntry(
                        id: UUID(),
                        username: item.ownerDisplayName ?? "unknown",
                        teamName: item.teamName,
                        totalPoints: item.totalPoints ?? 0,
                        rank: item.rank ?? (idx + 1)
                    )
                }
                if entries.isEmpty {
                    message = "League leaderboard is empty."
                } else {
                    message = nil
                }
            } catch {
                entries = []
                message = "Не удалось загрузить таблицу лиг."
            }
        }
    }
}
