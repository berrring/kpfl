//
//  ChampionDTO.swift
//  KPFL
//
//  Created by Аяз on 6/3/26.
//

import Foundation

struct ChampionDTO: Decodable {
    let id: Int64
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
