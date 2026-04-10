//
//  StandingDTO.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

struct StandingDTO: Decodable {
    let clubId: Int64
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let points: Int
    let form: [String]?

    private struct ClubRefDTO: Decodable {
        let id: Int64
    }

    enum CodingKeys: String, CodingKey {
        case club
        case played
        case won = "wins"
        case drawn = "draws"
        case lost = "losses"
        case goalsFor
        case goalsAgainst
        case points
        case form
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        clubId = try c.decode(ClubRefDTO.self, forKey: .club).id
        played = try c.decode(Int.self, forKey: .played)
        won = try c.decode(Int.self, forKey: .won)
        drawn = try c.decode(Int.self, forKey: .drawn)
        lost = try c.decode(Int.self, forKey: .lost)
        goalsFor = try c.decode(Int.self, forKey: .goalsFor)
        goalsAgainst = try c.decode(Int.self, forKey: .goalsAgainst)
        points = try c.decode(Int.self, forKey: .points)
        form = try c.decodeIfPresent([String].self, forKey: .form)
    }
}
