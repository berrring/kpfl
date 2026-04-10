//
//  MatchEventDTO.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

struct MatchEventDTO: Decodable {
    let id: String
    let matchId: String
    let minute: Int
    let clubId: String
    let type: String
    let playerId: String?
    let assistPlayerId: String?
}
