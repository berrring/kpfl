//
//  CreateTeamViewModel.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import Foundation

@MainActor
final class CreateTeamViewModel: ObservableObject {
    @Published var teamName: String = ""
    @Published var selectedLogoIndex: Int = 0
    @Published var alertMessage: String? = nil

    private let store = FantasyTeamStore()
    private let logoKey = "fantasy_team_logo"

    func createTeam() -> Bool {
        let trimmed = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            alertMessage = "Введите название команды"
            return false
        }

        let newTeam = FantasyTeam(
            id: UUID(),
            name: trimmed,
            players: [],
            budget: 100.0,
            totalPoints: 0
        )

        store.saveTeam(newTeam)
        UserDefaults.standard.set(selectedLogoIndex, forKey: logoKey)
        return true
    }
}
