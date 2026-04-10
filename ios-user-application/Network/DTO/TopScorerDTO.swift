//
//  TopScorerDTO.swift
//  KPFL
//
//  Created by Аяз on 6/3/26.
//

import Foundation

struct TopScorerDTO: Decodable {
    let id: Int64
    let rankNo: Int
    let playerName: String
    let positionName: String?
    let goals: Int
    let matchesPlayed: Int?
    let goalsPerMatch: Double?
    let sourceNote: String?
}
