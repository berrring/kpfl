//
//  ClubDTO.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

struct ClubDTO: Decodable {
    let id: Int64
    let name: String
    let shortName: String
    let city: String
    let founded: Int?
    let stadium: String?
    let capacity: Int?
    let primaryColorHex: String?
    let logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName = "abbr"
        case city
        case founded = "foundedYear"
        case stadium
        case capacity
        case primaryColorHex = "primaryColor"
        case logoUrl
    }
}
