//
//  GameweekViewModel.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

@MainActor
final class GameweekViewModel: ObservableObject {
    @Published private(set) var matches: [FantasyMatch] = []
    @Published private(set) var playerPoints: [FantasyPlayerGameweekPoints] = []
    @Published private(set) var currentGameweek = "Gameweek 1"
    @Published private(set) var isLoading = false
    @Published private(set) var infoMessage: String?

    private let api = KPFLAPI.shared

    func load() {
        Task {
            isLoading = true
            infoMessage = nil
            defer { isLoading = false }

            do {
                let round = try await api.fantasyCurrentRound()
                currentGameweek = "Gameweek \(round.roundNumber)"

                async let matchesDTO = api.matches()
                async let clubsDTO = api.clubs()
                let (allMatches, clubs) = try await (matchesDTO, clubsDTO)
                let clubNames = Dictionary(uniqueKeysWithValues: clubs.map { ($0.id, $0.shortName) })

                matches = allMatches
                    .filter { $0.round == round.roundNumber }
                    .prefix(8)
                    .map { item in
                        FantasyMatch(
                            id: UUID(),
                            home: item.homeClubId.flatMap { clubNames[$0] } ?? "Home",
                            away: item.awayClubId.flatMap { clubNames[$0] } ?? "Away",
                            time: item.time
                        )
                    }

                if matches.isEmpty {
                    matches = allMatches
                        .sorted { $0.dateISO < $1.dateISO }
                        .prefix(8)
                        .map { item in
                            FantasyMatch(
                                id: UUID(),
                                home: item.homeClubId.flatMap { clubNames[$0] } ?? "Home",
                                away: item.awayClubId.flatMap { clubNames[$0] } ?? "Away",
                                time: item.time
                            )
                        }
                    infoMessage = "Матчи этого тура не найдены, показаны ближайшие."
                }

                if UserDefaults.standard.string(forKey: KPFLAPI.authTokenKey) != nil {
                    let details = try await api.fantasyRoundDetails(roundNumber: round.roundNumber, seasonYear: round.seasonYear)
                    playerPoints = (details.playerPoints ?? [])
                        .sorted { ($0.appliedPoints ?? 0) > ($1.appliedPoints ?? 0) }
                        .prefix(10)
                        .map {
                            FantasyPlayerGameweekPoints(
                                id: UUID(),
                                name: "\($0.firstName) \($0.lastName)",
                                points: $0.appliedPoints ?? $0.rawPoints ?? 0
                            )
                        }
                    if playerPoints.isEmpty {
                        infoMessage = "Очки игроков для этого тура пока не рассчитаны."
                    }
                } else {
                    playerPoints = []
                    infoMessage = "Войди в аккаунт, чтобы видеть очки твоей команды."
                }
            } catch {
                matches = []
                playerPoints = []
                infoMessage = "Не удалось загрузить данные тура."
            }
        }
    }
}
