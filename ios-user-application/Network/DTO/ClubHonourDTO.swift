//
//  ClubHonourDTO.swift
//  KPFL
//
//  Created by Аяз on 6/3/26.
//

import Foundation

struct ClubHonourDTO: Decodable {
    let id: Int64
    let clubName: String
    let titles: Int
    let runnerUpCount: Int
    let thirdPlaceCount: Int
    let championshipYears: String?
}
