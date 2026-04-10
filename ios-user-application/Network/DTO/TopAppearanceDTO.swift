//
//  TopAppearanceDTO.swift
//  KPFL
//
//  Created by Аяз on 6/3/26.
//

import Foundation

struct TopAppearanceDTO: Decodable {
    let id: Int64
    let rankNo: Int
    let playerName: String
    let positionName: String?
    let matchesPlayed: Int
    let goals: Int?
    let sourceNote: String?
}
