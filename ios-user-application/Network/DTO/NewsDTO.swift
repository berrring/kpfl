//
//  NewsDTO.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

struct NewsDTO: Decodable {
    let id: Int64
    let title: String
    let summary: String
    let dateISO: String
    let tag: String
    let author: String?
    let clubId: Int64?
    let content: [String]

    private struct ClubRefDTO: Decodable {
        let id: Int64
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary = "shortText"
        case dateISO = "publishedAt"
        case tag
        case author
        case club
        case content
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int64.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        summary = try c.decodeIfPresent(String.self, forKey: .summary) ?? ""
        dateISO = try c.decode(String.self, forKey: .dateISO)
        tag = try c.decode(String.self, forKey: .tag)
        author = try c.decodeIfPresent(String.self, forKey: .author)
        clubId = try c.decodeIfPresent(ClubRefDTO.self, forKey: .club)?.id

        if let rawContent = try c.decodeIfPresent([String].self, forKey: .content), !rawContent.isEmpty {
            content = rawContent
        } else if summary.isEmpty {
            content = [title]
        } else {
            content = [summary]
        }
    }
}
