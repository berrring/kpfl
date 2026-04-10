//
//  PlayerDTO.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

struct PlayerDTO: Decodable {
    let id: Int64
    let clubId: Int64?
    let firstName: String
    let lastName: String
    let number: Int?
    let position: String?
    let isCoach: Bool?
    let nationality: String?
    let birthDateISO: String?
    let height: Int?
    let weight: Int?

    private struct ClubRefDTO: Decodable {
        let id: Int64
    }

    enum CodingKeys: String, CodingKey {
        case id
        case clubId
        case firstName
        case lastName
        case number
        case position
        case isCoach
        case nationality
        case birthDateISO = "birthDate"
        case height = "heightCm"
        case weight = "weightKg"
        case club
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int64.self, forKey: .id)
        firstName = try c.decode(String.self, forKey: .firstName)
        lastName = try c.decode(String.self, forKey: .lastName)
        number = try c.decodeIfPresent(Int.self, forKey: .number)
        position = try c.decodeIfPresent(String.self, forKey: .position)
        isCoach = try c.decodeIfPresent(Bool.self, forKey: .isCoach)
        nationality = try c.decodeIfPresent(String.self, forKey: .nationality)
        birthDateISO = try c.decodeIfPresent(String.self, forKey: .birthDateISO)
        height = try c.decodeIfPresent(Int.self, forKey: .height)
        weight = try c.decodeIfPresent(Int.self, forKey: .weight)

        if let directClubId = try c.decodeIfPresent(Int64.self, forKey: .clubId) {
            clubId = directClubId
        } else if let club = try c.decodeIfPresent(ClubRefDTO.self, forKey: .club) {
            clubId = club.id
        } else {
            clubId = nil
        }
    }
}
