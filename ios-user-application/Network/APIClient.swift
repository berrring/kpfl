//
//  APIClient.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//
//
//import Foundation
//
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case badStatus(Int)
//    case emptyData
//    case decoding(Error)
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "Invalid URL"
//        case .badStatus(let code): return "Bad status code: \(code)"
//        case .emptyData: return "Empty response"
//        case .decoding(let err): return "Decoding error: \(err.localizedDescription)"
//        }
//    }
//}
//final class APIClient {
//    let baseURL: URL
//    private let session: URLSession
//
//    init(baseURL: URL, session: URLSession = .shared) {
//        self.baseURL = baseURL
//        self.session = session
//    }
//
//    func get<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
//        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        let (data, response) = try await session.data(for: request)
//        guard let http = response as? HTTPURLResponse else {
//            throw APIError.badStatus(-1)
//        }
//        guard (200..<300).contains(http.statusCode) else {
//            throw APIError.badStatus(http.statusCode)
//        }
//        guard !data.isEmpty else { throw APIError.emptyData }
//
//        do {
//            return try JSONDecoder().decode(T.self, from: data)
//        } catch {
//            throw APIError.decoding(error)
//        }
//    }
//}
