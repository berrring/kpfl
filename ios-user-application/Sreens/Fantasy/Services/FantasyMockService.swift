//
//  FantasyMockService.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

final class FantasyMockService {
    func loadPlayers() -> [FantasyPlayer] {
        guard let url = Bundle.main.url(forResource: "fantasy_players", withExtension: "json") else {
            return fallbackPlayers()
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([FantasyPlayer].self, from: data)
            return decoded.isEmpty ? fallbackPlayers() : decoded
        } catch {
            print("FantasyMockService decode error: \(error)")
            return fallbackPlayers()
        }
    }

    private func fallbackPlayers() -> [FantasyPlayer] {
        [
            FantasyPlayer(id: 101, name: "Aidar Isakov", club: "Dordoi", position: "GK", price: 5.0, totalPoints: 0),
            FantasyPlayer(id: 102, name: "Maksat Japarov", club: "Alai", position: "GK", price: 5.5, totalPoints: 0),
            FantasyPlayer(id: 103, name: "Nurlan Arstanbek", club: "Neftchi", position: "GK", price: 4.5, totalPoints: 0),
            FantasyPlayer(id: 201, name: "Temir Kadyrov", club: "Dordoi", position: "DEF", price: 5.0, totalPoints: 0),
            FantasyPlayer(id: 202, name: "Ermek Asanov", club: "Neftchi", position: "DEF", price: 5.5, totalPoints: 0),
            FantasyPlayer(id: 203, name: "Adilet Omuraliev", club: "Alga", position: "DEF", price: 4.5, totalPoints: 0),
            FantasyPlayer(id: 204, name: "Bakyt Uulu", club: "Abdysh-Ata", position: "DEF", price: 6.0, totalPoints: 0),
            FantasyPlayer(id: 205, name: "Timur Eshmuratov", club: "Ilbirs", position: "DEF", price: 4.5, totalPoints: 0),
            FantasyPlayer(id: 206, name: "Aibek Daniyarov", club: "Dordoi", position: "DEF", price: 5.0, totalPoints: 0),
            FantasyPlayer(id: 301, name: "Bekzat Toktomamatov", club: "Abdysh-Ata", position: "MID", price: 7.5, totalPoints: 0),
            FantasyPlayer(id: 302, name: "Mirlan Karypbekov", club: "Alai", position: "MID", price: 8.0, totalPoints: 0),
            FantasyPlayer(id: 303, name: "Ilyaz Uulu", club: "Dordoi", position: "MID", price: 6.5, totalPoints: 0),
            FantasyPlayer(id: 304, name: "Eldiyar Mamatkulov", club: "Neftchi", position: "MID", price: 7.0, totalPoints: 0),
            FantasyPlayer(id: 305, name: "Kairat Saparov", club: "Alga", position: "MID", price: 6.0, totalPoints: 0),
            FantasyPlayer(id: 306, name: "Aman Turdubaev", club: "Ilbirs", position: "MID", price: 5.5, totalPoints: 0),
            FantasyPlayer(id: 307, name: "Nuradil Osmonov", club: "Abdysh-Ata", position: "MID", price: 6.5, totalPoints: 0),
            FantasyPlayer(id: 401, name: "Ruslan Tursunov", club: "Neftchi", position: "FWD", price: 8.5, totalPoints: 0),
            FantasyPlayer(id: 402, name: "Nurlan Sadykov", club: "Alga", position: "FWD", price: 9.0, totalPoints: 0),
            FantasyPlayer(id: 403, name: "Aibek Imanov", club: "Dordoi", position: "FWD", price: 8.0, totalPoints: 0),
            FantasyPlayer(id: 404, name: "Chyngyz Mederov", club: "Alai", position: "FWD", price: 7.5, totalPoints: 0),
            FantasyPlayer(id: 405, name: "Ernisbek Torobaev", club: "Abdysh-Ata", position: "FWD", price: 7.0, totalPoints: 0)
        ]
    }
}
