//
//  DataStore.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation
import SwiftUI

@MainActor
final class DataStore: ObservableObject {
    private let api = KPFLAPI()
    private static let userNameKey = "kpfl.auth.userName"

    @Published var clubs: [Club] = []
    @Published var standings: [Standing] = []
    @Published var matches: [Match] = []
    @Published var players: [Player] = []
    @Published var news: [NewsItem] = []
    @Published var events: [MatchEvent] = [] // Глобальные события
    @Published var champions: [ChampionSeason] = []
    @Published var clubHonours: [ClubHonour] = []
    @Published var historyRecords: [HistoryRecord] = []
    @Published var topScorersHistory: [TopScorerEntry] = []
    @Published var topAppearancesHistory: [TopAppearanceEntry] = []

    @Published var matchEventsByMatchId: [String: [MatchEvent]] = [:]

    // --- НОВОЕ: Состояние загрузки для экранов ---
    enum LoadState: Equatable {
        case idle, loading, loaded
        case failed(String)
    }
    @Published var loadState: LoadState = .idle
    
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Авторизация
    @Published var isSignedIn: Bool = false
    @Published var userName: String = ""
    @Published var authErrorMessage: String?

    init() {
        let savedName = UserDefaults.standard.string(forKey: Self.userNameKey) ?? ""
        let token = UserDefaults.standard.string(forKey: KPFLAPI.authTokenKey) ?? ""
        self.userName = savedName
        self.isSignedIn = !savedName.isEmpty && !token.isEmpty
    }

    func signIn(name: String, token: String) {
        self.userName = name
        self.isSignedIn = true
        self.authErrorMessage = nil
        UserDefaults.standard.set(name, forKey: Self.userNameKey)
        UserDefaults.standard.set(token, forKey: KPFLAPI.authTokenKey)
    }

    func signOut() {
        self.userName = ""
        self.isSignedIn = false
        UserDefaults.standard.removeObject(forKey: Self.userNameKey)
        UserDefaults.standard.removeObject(forKey: KPFLAPI.authTokenKey)
    }

    func login(email: String, password: String) async -> Bool {
        do {
            let response = try await api.login(email: email, password: password)
            guard let token = response.token, !token.isEmpty else {
                authErrorMessage = "Сервер не вернул токен авторизации."
                return false
            }
            let name = email.split(separator: "@").first.map(String.init) ?? "User"
            signIn(name: name, token: token)
            return true
        } catch {
            authErrorMessage = error.localizedDescription
            return false
        }
    }

    func register(name: String, email: String, password: String) async -> Bool {
        do {
            let response = try await api.register(name: name, email: email, password: password)
            guard let token = response.token, !token.isEmpty else {
                authErrorMessage = "Сервер не вернул токен авторизации."
                return false
            }
            signIn(name: name, token: token)
            return true
        } catch {
            authErrorMessage = error.localizedDescription
            return false
        }
    }

    func loadAllIfNeeded() async {
        if clubs.isEmpty && loadState != .loading {
            await loadAll()
        }
    }

    // --- НОВОЕ: Для pull-to-refresh ---
    func refreshAll() async {
        await loadAll()
    }

    func loadAll() async {
        loadState = .loading
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Запрашиваем DTO через текущий API-клиент
            async let clubsReq: [ClubDTO] = api.clubs()
            async let standingsReq: [StandingDTO] = api.standings()
            async let matchesReq: [MatchDTO] = api.matches()
            async let playersReq: [PlayerDTO] = api.players()
            async let newsReq: [NewsDTO] = api.news()
            async let eventsReq: [MatchEventDTO] = api.matchEvents()
            async let championsReq: [ChampionDTO] = api.champions()
            async let honoursReq: [ClubHonourDTO] = api.clubHonours()
            async let recordsReq: [HistoryRecordDTO] = api.historyRecords()
            async let topScorersReq: [TopScorerDTO] = api.topScorers()
            async let topAppsReq: [TopAppearanceDTO] = api.topAppearances()

            let (cDTO, sDTO, mDTO, pDTO, nDTO, eDTO, chDTO, hDTO, rDTO, tsDTO, taDTO) = try await (
                clubsReq,
                standingsReq,
                matchesReq,
                playersReq,
                newsReq,
                eventsReq,
                championsReq,
                honoursReq,
                recordsReq,
                topScorersReq,
                topAppsReq
            )

            // Мапим DTO в чистые модели
            self.clubs = cDTO.map { $0.toModel() }
            self.standings = sDTO.map { $0.toModel() }
            self.matches = mDTO.map { $0.toModel() }
            self.players = pDTO.map { $0.toModel() }
            self.news = nDTO.map { $0.toModel() }
            self.events = eDTO.map { $0.toModel() }
            self.champions = chDTO.map { $0.toModel() }.sorted { $0.seasonYear > $1.seasonYear }
            self.clubHonours = hDTO.map { $0.toModel() }.sorted { $0.titles > $1.titles }
            self.historyRecords = rDTO.map { $0.toModel() }
            self.topScorersHistory = tsDTO.map { $0.toModel() }.sorted { $0.rankNo < $1.rankNo }
            self.topAppearancesHistory = taDTO.map { $0.toModel() }.sorted { $0.rankNo < $1.rankNo }

            self.loadState = .loaded

        } catch {
            self.errorMessage = "Не удалось загрузить данные с сервера."
            self.loadState = .failed(error.localizedDescription)
            print("API Load Error: \(error.localizedDescription)")
        }
    }

    func loadMatchEvents(matchId: String) async {
        if matchEventsByMatchId[matchId] != nil { return }

        do {
            // В текущем API есть общий endpoint событий, фильтруем по matchId локально
            let fetchedEventsDTO: [MatchEventDTO] = try await api.matchEvents()
            matchEventsByMatchId[matchId] = fetchedEventsDTO
                .map { $0.toModel() }
                .filter { $0.matchId == matchId }
        } catch {
            print("Ошибка загрузки событий матча \(matchId): \(error)")
            matchEventsByMatchId[matchId] = []
        }
    }

    // Хелперы для экранов
    func club(_ id: String) -> Club? { clubs.first { $0.id == id } }
    func player(_ id: String) -> Player? { players.first { $0.id == id } }
    func newsItem(_ id: String) -> NewsItem? { news.first { $0.id == id } }
    func match(_ id: String) -> Match? { matches.first { $0.id == id } }
    func matchEvents(_ matchId: String) -> [MatchEvent] { matchEventsByMatchId[matchId] ?? [] }

    func champion(for year: Int) -> ChampionSeason? {
        champions.first { $0.seasonYear == year }
    }
    
    // --- НОВОЕ: Выборка игроков конкретного клуба (для ClubProfileScreen) ---
    func clubPlayers(_ clubId: String) -> [Player] {
        return players.filter { $0.clubId == clubId }
    }
}
