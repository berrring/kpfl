//
//  PlayerSelectionViewModel.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

@MainActor
final class PlayerSelectionViewModel: ObservableObject {
    enum SortOption: String, CaseIterable {
        case price = "Price"
        case points = "Points"
    }

    @Published private(set) var players: [FantasyPlayer] = []
    @Published private(set) var team: FantasyTeam? = nil
    @Published var selectedPosition: String = "All"
    @Published var selectedClub: String = "All"
    @Published var sortOption: SortOption = .points
    @Published var alertMessage: String? = nil
    @Published private(set) var isLoading = false

    private let store = FantasyTeamStore()
    private let service = FantasyMockService()
    private let api = KPFLAPI.shared

    private let positionLimits: [String: Int] = [
        "GK": 2,
        "DEF": 5,
        "MID": 5,
        "FWD": 3
    ]
    private let maxPlayersFromClub = 3
    private let squadSize = 15

    var clubs: [String] {
        let unique = Set(players.map { $0.club })
        return ["All"] + unique.sorted()
    }

    func load() {
        if players.isEmpty {
            players = service.loadPlayers()
        }
        Task {
            await loadPlayersAndTeam()
        }
    }

    func filteredPlayers() -> [FantasyPlayer] {
        var list = players

        if selectedPosition != "All" {
            list = list.filter { $0.position == selectedPosition }
        }

        if selectedClub != "All" {
            list = list.filter { $0.club == selectedClub }
        }

        switch sortOption {
        case .price:
            list.sort { $0.price < $1.price }
        case .points:
            list.sort { $0.totalPoints > $1.totalPoints }
        }

        return list
    }

    func addPlayer(_ player: FantasyPlayer) -> Bool {
        guard var current = team else {
            alertMessage = "Сначала создайте команду"
            return false
        }

        if current.players.contains(where: { $0.id == player.id }) {
            alertMessage = "Игрок уже в составе"
            return false
        }

        if current.players.count >= squadSize {
            alertMessage = "Состав уже полный (15 игроков)"
            return false
        }

        let positionCount = current.players.filter { $0.position == player.position }.count
        if let limit = positionLimits[player.position], positionCount >= limit {
            alertMessage = "Лимит для позиции \(player.position) достигнут"
            return false
        }

        let clubCount = current.players.filter { $0.club == player.club }.count
        if clubCount >= maxPlayersFromClub {
            alertMessage = "Максимум 3 игрока из одного клуба"
            return false
        }

        if current.budget < player.price {
            alertMessage = "Недостаточно бюджета"
            return false
        }

        current.players.append(player)
        current.budget = (current.budget - player.price)
        current.totalPoints = current.players.reduce(0) { $0 + $1.totalPoints }
        store.saveTeam(current)
        team = current

        if current.players.count == squadSize {
            Task { await syncFullSquadIfPossible() }
        }

        return true
    }

    private func loadPlayersAndTeam() async {
        isLoading = true
        defer { isLoading = false }

        team = store.loadTeam().map { normalizeTeam($0) }

        do {
            async let playersDTO = api.players()
            async let clubsDTO = api.clubs()
            let (pDTO, cDTO) = try await (playersDTO, clubsDTO)
            let clubById = Dictionary(uniqueKeysWithValues: cDTO.map { ($0.id, $0.shortName) })
            players = pDTO.map { dto in
                let fullName = "\(dto.firstName) \(dto.lastName)".trimmingCharacters(in: .whitespaces)
                let clubName = dto.clubId.flatMap { clubById[$0] } ?? "Unknown"
                return FantasyPlayer(
                    id: Int(dto.id),
                    name: fullName,
                    club: clubName,
                    position: mapPosition(dto.position),
                    price: defaultPrice(for: dto.position, id: dto.id),
                    totalPoints: 0
                )
            }
            if players.isEmpty {
                players = service.loadPlayers()
            }
        } catch {
            players = service.loadPlayers()
            alertMessage = "Проблема с сервером игроков, показаны локальные данные."
        }

        await loadRemoteTeamIfAvailable()
    }

    private func loadRemoteTeamIfAvailable() async {
        guard UserDefaults.standard.string(forKey: KPFLAPI.authTokenKey) != nil else { return }

        do {
            let overview = try await api.fantasyMyTeam()
            let squad = try await api.fantasyMySquad()

            let mappedPlayers = squad.players.map { dto in
                FantasyPlayer(
                    id: Int(dto.playerId),
                    name: "\(dto.firstName) \(dto.lastName)",
                    club: dto.clubName ?? "Unknown",
                    position: mapPosition(dto.position),
                    price: dto.currentPrice ?? dto.acquiredPrice ?? 5.0,
                    totalPoints: 0
                )
            }

            let resolved = FantasyTeam(
                id: team?.id ?? UUID(),
                name: overview.teamName,
                players: mappedPlayers,
                budget: overview.currentBudget,
                totalPoints: overview.totalPoints,
                remoteTeamId: overview.teamId,
                seasonYear: overview.seasonYear
            )
            team = normalizeTeam(resolved)
            store.saveTeam(resolved)
        } catch {
            // A missing backend team is a valid state for a new user.
        }
    }

    private func syncFullSquadIfPossible() async {
        guard var current = team, current.players.count == squadSize else { return }
        guard UserDefaults.standard.string(forKey: KPFLAPI.authTokenKey) != nil else { return }

        let playerIds = current.players.map { Int64($0.id) }

        do {
            if current.remoteTeamId == nil {
                let created = try await api.createFantasyTeam(name: current.name, playerIds: playerIds)
                current.remoteTeamId = created.teamId
                current.seasonYear = created.seasonYear
                current.budget = created.currentBudget
                current.totalPoints = created.totalPoints
            } else {
                let updated = try await api.updateFantasySquad(playerIds: playerIds)
                current.budget = updated.currentBudget
                current.totalPoints = updated.totalPoints
                current.seasonYear = updated.seasonYear
            }
            team = normalizeTeam(current)
            store.saveTeam(current)
            alertMessage = "Состав синхронизирован с сервером"
        } catch {
            alertMessage = "Не удалось синхронизировать состав: \(error.localizedDescription)"
        }
    }

    private func mapPosition(_ raw: String?) -> String {
        switch raw?.uppercased() {
        case "GK": return "GK"
        case "DF", "DEF": return "DEF"
        case "MF", "MID": return "MID"
        case "FW", "FWD": return "FWD"
        default: return "MID"
        }
    }

    private func defaultPrice(for position: String?, id: Int64) -> Double {
        let base: Double
        switch position?.uppercased() {
        case "GK": base = 4.5
        case "DF", "DEF": base = 5.0
        case "MF", "MID": base = 6.5
        case "FW", "FWD": base = 7.0
        default: base = 5.5
        }
        let delta = Double((id % 6)) * 0.5
        return min(base + delta, 12.5)
    }

    private func normalizeTeam(_ team: FantasyTeam) -> FantasyTeam {
        var updated = team
        var seen = Set<Int>()
        updated.players = updated.players.filter { seen.insert($0.id).inserted }
        updated.totalPoints = updated.players.reduce(0) { $0 + $1.totalPoints }
        return updated
    }
}
