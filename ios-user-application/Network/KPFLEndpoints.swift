//
//  KPFLEndpoints.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

enum KPFLEndpoints {

    static let clubs = "/api/clubs"
    static func club(id: String) -> String { "/api/clubs/\(id)" }

    static let standings = "/api/standings"

    static let matches = "/api/matches"
    static func match(id: String) -> String { "/api/matches/\(id)" }
    static func matchEvents(matchId: String) -> String { "/api/matches/\(matchId)/events" }

    static let players = "/api/players"
    static func player(id: String) -> String { "/api/players/\(id)" }

    static let news = "/api/news"
    static func newsItem(id: String) -> String { "/api/news/\(id)" }

    static let clubHonours = "/api/history/club-honours"
    static let champions = "/api/history/champions"
    static func champion(seasonYear: Int) -> String { "/api/history/champions/\(seasonYear)" }
    static let historyRecords = "/api/history/records"
    static let topScorers = "/api/history/top-scorers"
    static let topAppearances = "/api/history/top-appearances"

    static let login = "/api/auth/login"
}
