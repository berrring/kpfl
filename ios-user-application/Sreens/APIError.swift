//
//  APIError.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case badStatus(Int, String)
    case emptyData
    case decoding(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badStatus(let code, let body):
            return "HTTP \(code): \(body)"
        case .emptyData:
            return "Empty response"
        case .decoding(let msg):
            return "Decoding error: \(msg)"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        }
    }
}
