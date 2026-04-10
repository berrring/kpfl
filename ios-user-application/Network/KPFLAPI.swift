//
//  KPFLAPI.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

final class KPFLAPI {
    static let shared = KPFLAPI()
    static let authTokenKey = "kpfl.auth.token"

    private let baseURL = URL(string: "https://kpfl.onrender.com")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    private func makeURL(_ path: String) throws -> URL {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        return url
    }

    private func makeURL(_ path: String, query: [URLQueryItem]) throws -> URL {
        let base = try makeURL(path)
        guard !query.isEmpty else { return base }
        guard var comps = URLComponents(url: base, resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }
        comps.queryItems = query
        guard let url = comps.url else { throw APIError.invalidURL }
        return url
    }

    private func request<T: Decodable>(_ path: String) async throws -> T {
        let url = try makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await send(req)
    }

    private func request<T: Decodable>(_ path: String, query: [URLQueryItem]) async throws -> T {
        let url = try makeURL(path, query: query)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await send(req)
    }

    private func authorizedRequest<T: Decodable>(_ path: String) async throws -> T {
        let url = try makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        try applyAuthorization(to: &req)
        return try await send(req)
    }

    private func authorizedRequest<T: Decodable>(_ path: String, query: [URLQueryItem]) async throws -> T {
        let url = try makeURL(path, query: query)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        try applyAuthorization(to: &req)
        return try await send(req)
    }

    private func applyAuthorization(to request: inout URLRequest) throws {
        guard let token = UserDefaults.standard.string(forKey: Self.authTokenKey), !token.isEmpty else {
            throw APIError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    private func requestBody<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let url = try makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        return try await send(req)
    }

    private func authorizedRequestBody<T: Decodable, B: Encodable>(_ method: String, path: String, body: B) async throws -> T {
        let url = try makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        try applyAuthorization(to: &req)
        return try await send(req)
    }

    private func send<T: Decodable>(_ req: URLRequest) async throws -> T {
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.emptyData }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.badStatus(http.statusCode, body)
        }
        guard !data.isEmpty else { throw APIError.emptyData }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }

    func clubs() async throws -> [ClubDTO] {
        let list: [ClubDTO] = try await request("/api/clubs")
        guard !list.isEmpty else { return [] }
        var details: [ClubDTO] = []
        details.reserveCapacity(list.count)

        for club in list {
            do {
                let detail: ClubDTO = try await request("/api/clubs/\(club.id)")
                details.append(detail)
            } catch {
                details.append(club)
            }
        }

        return details.isEmpty ? list : details
    }

    func players() async throws -> [PlayerDTO] {
        let list: [PlayerDTO] = try await request("/api/players")
        guard !list.isEmpty else { return [] }
        var details: [PlayerDTO] = []
        details.reserveCapacity(list.count)

        for player in list {
            do {
                let detail: PlayerDTO = try await request("/api/players/\(player.id)")
                details.append(detail)
            } catch {
                details.append(player)
            }
        }

        return details.isEmpty ? list : details
    }

    func matches() async throws -> [MatchDTO] {
        let list: [MatchDTO] = try await request("/api/matches")
        var details: [MatchDTO] = []
        details.reserveCapacity(list.count)

        for match in list {
            let detail: MatchDTO = try await request("/api/matches/\(match.id)")
            details.append(detail)
        }

        return details
    }

    func standings() async throws -> [StandingDTO] {
        try await request("/api/standings")
    }

    func clubHonours() async throws -> [ClubHonourDTO] {
        try await request("/api/history/club-honours")
    }

    func champions(fromYear: Int? = nil, toYear: Int? = nil) async throws -> [ChampionDTO] {
        var items: [URLQueryItem] = []
        if let fromYear {
            items.append(URLQueryItem(name: "fromYear", value: "\(fromYear)"))
        }
        if let toYear {
            items.append(URLQueryItem(name: "toYear", value: "\(toYear)"))
        }
        if items.isEmpty {
            return try await request("/api/history/champions")
        }
        return try await request("/api/history/champions", query: items)
    }

    func champion(seasonYear: Int) async throws -> ChampionDTO {
        try await request("/api/history/champions/\(seasonYear)")
    }

    func historyRecords() async throws -> [HistoryRecordDTO] {
        try await request("/api/history/records")
    }

    func topScorers() async throws -> [TopScorerDTO] {
        try await request("/api/history/top-scorers")
    }

    func topAppearances() async throws -> [TopAppearanceDTO] {
        try await request("/api/history/top-appearances")
    }

    func news() async throws -> [NewsDTO] {
        let list: [NewsDTO] = try await request("/api/news")
        var details: [NewsDTO] = []
        details.reserveCapacity(list.count)

        for item in list {
            let detail: NewsDTO = try await request("/api/news/\(item.id)")
            details.append(detail)
        }

        return details
    }

    func matchEvents() async throws -> [MatchEventDTO] {
        []
    }

    struct RegisterBody: Encodable {
        let displayName: String
        let email: String
        let password: String
    }
    struct LoginBody: Encodable {
        let email: String
        let password: String
    }
    struct AuthResponseDTO: Decodable {
        let token: String?
    }

    func register(name: String, email: String, password: String) async throws -> AuthResponseDTO {
        try await requestBody("/auth/register", body: RegisterBody(displayName: name, email: email, password: password))
    }

    func login(email: String, password: String) async throws -> AuthResponseDTO {
        try await requestBody("/auth/login", body: LoginBody(email: email, password: password))
    }

    func fantasyCurrentRound() async throws -> FantasyRoundInfoDTO {
        try await request("/api/fantasy/rounds/current")
    }

    func fantasyLeaderboard(seasonYear: Int? = nil) async throws -> [FantasyLeaderboardEntryDTO] {
        var query: [URLQueryItem] = []
        if let seasonYear {
            query.append(URLQueryItem(name: "seasonYear", value: "\(seasonYear)"))
        }
        if query.isEmpty {
            return try await request("/api/fantasy/leaderboard")
        }
        return try await request("/api/fantasy/leaderboard", query: query)
    }

    func fantasyLeagueLeaderboard(leagueId: Int64) async throws -> [FantasyLeaderboardEntryDTO] {
        try await request("/api/fantasy/leagues/\(leagueId)/leaderboard")
    }

    func fantasyMyTeam() async throws -> FantasyTeamOverviewDTO {
        try await authorizedRequest("/me/fantasy/team")
    }

    func fantasyMySquad() async throws -> FantasyTeamSquadDTO {
        try await authorizedRequest("/me/fantasy/team/squad")
    }

    func fantasyRoundDetails(roundNumber: Int, seasonYear: Int? = nil) async throws -> FantasyTeamRoundDTO {
        var query: [URLQueryItem] = []
        if let seasonYear {
            query.append(URLQueryItem(name: "seasonYear", value: "\(seasonYear)"))
        }
        return try await authorizedRequest("/me/fantasy/team/rounds/\(roundNumber)", query: query)
    }

    func fantasyHistory(seasonYear: Int? = nil) async throws -> [FantasyHistoryItemDTO] {
        var query: [URLQueryItem] = []
        if let seasonYear {
            query.append(URLQueryItem(name: "seasonYear", value: "\(seasonYear)"))
        }
        if query.isEmpty {
            return try await authorizedRequest("/me/fantasy/team/history")
        }
        return try await authorizedRequest("/me/fantasy/team/history", query: query)
    }

    func fantasyMyLeaderboard(seasonYear: Int? = nil) async throws -> [FantasyLeaderboardEntryDTO] {
        var query: [URLQueryItem] = []
        if let seasonYear {
            query.append(URLQueryItem(name: "seasonYear", value: "\(seasonYear)"))
        }
        if query.isEmpty {
            return try await authorizedRequest("/me/fantasy/leaderboard")
        }
        return try await authorizedRequest("/me/fantasy/leaderboard", query: query)
    }

    func fantasyMyLeagues() async throws -> [FantasyLeagueDTO] {
        try await authorizedRequest("/me/fantasy/leagues")
    }

    func fantasyCreateLeague(name: String) async throws -> FantasyLeagueDTO {
        let body = FantasyLeagueCreateRequestDTO(name: name)
        return try await authorizedRequestBody("POST", path: "/me/fantasy/leagues", body: body)
    }

    func fantasyJoinLeague(code: String) async throws -> FantasyLeagueDTO {
        let body = FantasyLeagueJoinRequestDTO(code: code)
        return try await authorizedRequestBody("POST", path: "/me/fantasy/leagues/join", body: body)
    }

    func createFantasyTeam(name: String, playerIds: [Int64]) async throws -> FantasyTeamOverviewDTO {
        let body = FantasyTeamCreateRequestDTO(name: name, playerIds: playerIds)
        return try await authorizedRequestBody("POST", path: "/me/fantasy/team", body: body)
    }

    func updateFantasySquad(playerIds: [Int64]) async throws -> FantasyTeamSquadDTO {
        let body = FantasySquadUpdateRequestDTO(playerIds: playerIds)
        return try await authorizedRequestBody("PUT", path: "/me/fantasy/team/squad", body: body)
    }

    func saveFantasyLineup(
        seasonYear: Int?,
        roundNumber: Int,
        starterPlayerIds: [Int64],
        benchPlayerIds: [Int64],
        captainPlayerId: Int64,
        viceCaptainPlayerId: Int64
    ) async throws -> FantasyTeamRoundDTO {
        let body = FantasyLineupUpdateRequestDTO(
            seasonYear: seasonYear,
            roundNumber: roundNumber,
            starterPlayerIds: starterPlayerIds,
            benchPlayerIds: benchPlayerIds,
            captainPlayerId: captainPlayerId,
            viceCaptainPlayerId: viceCaptainPlayerId
        )
        return try await authorizedRequestBody("PUT", path: "/me/fantasy/team/lineup", body: body)
    }

    func makeFantasyTransfers(
        seasonYear: Int?,
        roundNumber: Int,
        transfers: [FantasyTransferItemRequestDTO]
    ) async throws -> FantasyTransferResultDTO {
        let body = FantasyTransferRequestDTO(seasonYear: seasonYear, roundNumber: roundNumber, transfers: transfers)
        return try await authorizedRequestBody("POST", path: "/me/fantasy/team/transfers", body: body)
    }
}
