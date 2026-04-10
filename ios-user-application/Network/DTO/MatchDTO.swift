//
//  MatchDTO.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

struct MatchDTO: Decodable {
    let id: Int64
    let dateISO: String
    let time: String
    let round: Int?
    let stadium: String?
    let attendance: Int?
    let status: String
    let minute: Int?
    let homeClubId: Int64?
    let awayClubId: Int64?
    let homeScore: Int
    let awayScore: Int

    private struct ClubRefDTO: Decodable {
        let id: Int64
    }

    enum CodingKeys: String, CodingKey {
        case id
        case dateTime
        case status
        case round
        case stadium
        case attendance
        case minute
        case homeClub
        case awayClub
        case score
        case homeGoals
        case awayGoals
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int64.self, forKey: .id)
        let dateTime = try c.decode(String.self, forKey: .dateTime)
        status = try c.decode(String.self, forKey: .status)
        round = try c.decodeIfPresent(Int.self, forKey: .round)
        stadium = try c.decodeIfPresent(String.self, forKey: .stadium)
        attendance = try c.decodeIfPresent(Int.self, forKey: .attendance)
        minute = try c.decodeIfPresent(Int.self, forKey: .minute)

        homeClubId = try c.decodeIfPresent(ClubRefDTO.self, forKey: .homeClub)?.id
        awayClubId = try c.decodeIfPresent(ClubRefDTO.self, forKey: .awayClub)?.id

        if let homeGoals = try c.decodeIfPresent(Int.self, forKey: .homeGoals),
           let awayGoals = try c.decodeIfPresent(Int.self, forKey: .awayGoals) {
            homeScore = homeGoals
            awayScore = awayGoals
        } else if let score = try c.decodeIfPresent(String.self, forKey: .score) {
            let parsed = score
                .split(separator: ":")
                .map { Int($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
            homeScore = parsed.indices.contains(0) ? parsed[0] : 0
            awayScore = parsed.indices.contains(1) ? parsed[1] : 0
        } else {
            homeScore = 0
            awayScore = 0
        }

        let parts = dateTime.split(separator: "T", maxSplits: 1).map(String.init)
        dateISO = parts.first ?? dateTime
        let timePart = parts.count > 1 ? parts[1] : "00:00:00"
        time = String(timePart.prefix(5))
    }
}
