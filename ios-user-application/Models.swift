//
//  Models.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

enum PlayerPosition: String, Codable {
    case GK, DF, MF, FW // Сокращения как в твоем Squad view
}

struct Club: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let city: String
    let founded: Int
    let stadium: String
    let capacity: Int
    let primaryColorHex: String
}

struct Player: Identifiable, Codable, Hashable {
    let id: String
    let clubId: String
    let firstName: String
    let lastName: String
    let number: Int
    let position: PlayerPosition?
    let isCoach: Bool
    let nationality: String
    let birthDateISO: String
    let height: Int?
    let weight: Int?
}

enum MatchStatus: String, Codable {
    case scheduled = "Scheduled"
    case live = "Live"
    case final = "Final"
}

struct Match: Identifiable, Codable, Hashable {
    let id: String
    let dateISO: String
    let time: String
    let round: Int
    let stadium: String
    let attendance: Int?
    let status: MatchStatus
    let minute: Int?
    let homeClubId: String
    let awayClubId: String
    let homeScore: Int
    let awayScore: Int
}

struct Standing: Identifiable, Codable, Hashable {
    var id: String { clubId }
    let clubId: String
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let points: Int
    let form: [String] // "W"/"D"/"L"
}

enum NewsTag: String, Codable, CaseIterable {
    case Transfer, Matchday, Club, League, Injury, Interview
}

struct NewsItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let summary: String
    let dateISO: String
    let tag: NewsTag
    let author: String?
    let clubId: String?
    let content: [String]
}

enum EventType: String, Codable {
    case GOAL, YELLOW, RED
}

struct MatchEvent: Identifiable, Codable, Hashable {
    let id: String
    let matchId: String
    let minute: Int
    let clubId: String
    let type: EventType
    let playerId: String
    let assistPlayerId: String?
}

struct ChampionSeason: Identifiable, Codable, Hashable {
    let id: String
    let seasonYear: Int
    let champion: String
    let championTitleNo: Int?
    let runnerUp: String?
    let thirdPlace: String?
    let topScorer: String?
    let topScorerGoals: Int?
    let topScorerClub: String?
    let playerOfYear: String?
    let notes: String?
}

struct ClubHonour: Identifiable, Codable, Hashable {
    let id: String
    let clubName: String
    let titles: Int
    let runnerUpCount: Int
    let thirdPlaceCount: Int
    let championshipYears: String?
}
struct TopScorerEntry: Identifiable, Codable, Hashable {
    let id: String
    let rankNo: Int
    let playerName: String
    let positionName: String?
    let goals: Int
    let matchesPlayed: Int?
    let goalsPerMatch: Double?
    let sourceNote: String?
}

struct TopAppearanceEntry: Identifiable, Codable, Hashable {
    let id: String
    let rankNo: Int
    let playerName: String
    let positionName: String?
    let matchesPlayed: Int
    let goals: Int?
    let sourceNote: String?
}

struct HistoryRecord: Identifiable, Codable, Hashable {
    let id: String
    let recordKey: String
    let recordValue: String
    let sourceNote: String?
}

