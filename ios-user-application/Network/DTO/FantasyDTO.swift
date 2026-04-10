//
//  FantasyDTO.swift
//  KPFL
//
//  Created by Codex on 9/4/26.
//

import Foundation

struct FantasyRoundInfoDTO: Decodable {
    let seasonYear: Int?
    let roundNumber: Int
    let lockAt: String?
    let locked: Bool?
}

struct FantasyLeaderboardEntryDTO: Decodable {
    let rank: Int?
    let teamId: Int64?
    let teamName: String
    let ownerDisplayName: String?
    let totalPoints: Int?
}

struct FantasyTeamOverviewDTO: Decodable {
    let teamId: Int64
    let teamName: String
    let seasonYear: Int
    let totalPoints: Int
    let currentBudget: Double
    let nextRoundNumber: Int?
    let nextRoundLock: String?
    let active: Bool?
}

struct FantasySquadPlayerDTO: Decodable {
    let playerId: Int64
    let firstName: String
    let lastName: String
    let position: String
    let clubId: Int64?
    let clubName: String?
    let clubAbbr: String?
    let currentPrice: Double?
    let acquiredPrice: Double?
}

struct FantasyTeamSquadDTO: Decodable {
    let teamId: Int64
    let teamName: String
    let seasonYear: Int
    let totalPoints: Int
    let currentBudget: Double
    let squadValue: Double?
    let players: [FantasySquadPlayerDTO]
}

struct FantasyPlayerRoundPointsDTO: Decodable {
    let playerId: Int64
    let firstName: String
    let lastName: String
    let position: String?
    let clubName: String?
    let rawPoints: Int?
    let appliedPoints: Int?
}

struct FantasyMatchLineupPlayerDTO: Decodable {
    let playerId: Int64
    let firstName: String
    let lastName: String
    let position: String?
    let clubName: String?
    let starter: Bool?
    let captain: Bool?
    let viceCaptain: Bool?
}

struct FantasyTeamRoundDTO: Decodable {
    let seasonYear: Int?
    let roundNumber: Int
    let points: Int?
    let transferPenalty: Int?
    let finalPoints: Int?
    let lineup: [FantasyMatchLineupPlayerDTO]?
    let playerPoints: [FantasyPlayerRoundPointsDTO]?
}

struct FantasyTeamCreateRequestDTO: Encodable {
    let name: String
    let playerIds: [Int64]
}

struct FantasySquadUpdateRequestDTO: Encodable {
    let playerIds: [Int64]
}

struct FantasyLineupUpdateRequestDTO: Encodable {
    let seasonYear: Int?
    let roundNumber: Int
    let starterPlayerIds: [Int64]
    let benchPlayerIds: [Int64]
    let captainPlayerId: Int64
    let viceCaptainPlayerId: Int64
}

struct FantasyTransferItemRequestDTO: Encodable {
    let playerOutId: Int64
    let playerInId: Int64
}

struct FantasyTransferRequestDTO: Encodable {
    let seasonYear: Int?
    let roundNumber: Int
    let transfers: [FantasyTransferItemRequestDTO]
}

struct FantasyTransferResultDTO: Decodable {
    let teamId: Int64?
    let seasonYear: Int?
    let roundNumber: Int?
    let transfersMade: Int?
    let freeTransfersUsed: Int?
    let transferPenalty: Int?
    let currentBudget: Double?
    let lineupReset: Bool?
}

struct FantasyLeagueDTO: Decodable {
    let leagueId: Int64
    let name: String
    let code: String?
    let isPrivate: Bool?
    let seasonYear: Int?
    let ownerDisplayName: String?
    let memberCount: Int?
}

struct FantasyLeagueCreateRequestDTO: Encodable {
    let name: String
}

struct FantasyLeagueJoinRequestDTO: Encodable {
    let code: String
}

struct FantasyHistoryItemDTO: Decodable {
    let seasonYear: Int?
    let roundNumber: Int?
    let points: Int?
    let transferPenalty: Int?
    let finalPoints: Int?
    let cumulativePoints: Int?
    let rankSnapshot: Int?
}
