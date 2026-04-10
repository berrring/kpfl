//
//  FantasyModels.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

struct FantasyPlayer: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let club: String
    let position: String // GK DEF MID FWD
    let price: Double
    let totalPoints: Int
}

struct FantasyTeam: Identifiable, Codable {
    let id: UUID
    var name: String
    var players: [FantasyPlayer]
    var budget: Double
    var totalPoints: Int
    var remoteTeamId: Int64?
    var seasonYear: Int?

    init(
        id: UUID = UUID(),
        name: String,
        players: [FantasyPlayer],
        budget: Double,
        totalPoints: Int,
        remoteTeamId: Int64? = nil,
        seasonYear: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.budget = budget
        self.totalPoints = totalPoints
        self.remoteTeamId = remoteTeamId
        self.seasonYear = seasonYear
    }
}

struct FantasyLeagueEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let username: String
    let teamName: String
    let totalPoints: Int
    let rank: Int
}

struct FantasyMatch: Identifiable, Codable, Hashable {
    let id: UUID
    let home: String
    let away: String
    let time: String
}

struct FantasyPlayerGameweekPoints: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let points: Int
}
