//
//  FantasyScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct FantasyScreen: View {
    let showBack: Bool
    let onBack: () -> Void
    let onManageTeam: () -> Void
    let onCreateTeam: () -> Void
    let onJoinLeague: () -> Void
    let onCreateLeague: () -> Void
    let onOpenGameweek: () -> Void

    var body: some View {
        FantasyHomeView(
            showBack: showBack,
            onBack: onBack,
            onManageTeam: onManageTeam,
            onCreateTeam: onCreateTeam,
            onJoinLeague: onJoinLeague,
            onCreateLeague: onCreateLeague,
            onOpenGameweek: onOpenGameweek
        )
    }
}
