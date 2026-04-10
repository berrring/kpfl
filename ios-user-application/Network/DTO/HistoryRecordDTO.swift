//
//  HistoryRecordDTO.swift
//  KPFL
//
//  Created by Аяз on 6/3/26.
//

import Foundation

struct HistoryRecordDTO: Decodable {
    let id: Int64
    let recordKey: String
    let recordValue: String
    let sourceNote: String?
}
