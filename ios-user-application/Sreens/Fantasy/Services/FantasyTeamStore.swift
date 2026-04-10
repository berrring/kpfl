//
//  FantasyTeamStore.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

struct FantasyTeamStore {
    private let key = "fantasy_team_data"

    func loadTeam() -> FantasyTeam? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(FantasyTeam.self, from: data)
    }

    func saveTeam(_ team: FantasyTeam) {
        if let data = try? JSONEncoder().encode(team) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clearTeam() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
