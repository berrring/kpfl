//
//  MyTeamView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI
import Foundation

struct MyTeamView: View {
    @StateObject private var viewModel = MyTeamViewModel()

    let onBack: () -> Void
    let onAddPlayer: () -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "My Team", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.teamName.isEmpty ? "Your Team" : viewModel.teamName)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))
                            HStack {
                                Text("Budget Left")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text("$\(String(format: "%.1f", viewModel.budgetLeft))M")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(Color(hex: "#0A1628"))
                            }
                            HStack {
                                Text("Total Points")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text("\(viewModel.totalPoints)")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(Color(hex: "#0A1628"))
                            }
                        }
                    }

                    squadSection(title: "GK", limit: 2, players: viewModel.players(for: "GK"))
                    squadSection(title: "DEF", limit: 5, players: viewModel.players(for: "DEF"))
                    squadSection(title: "MID", limit: 5, players: viewModel.players(for: "MID"))
                    squadSection(title: "FWD", limit: 3, players: viewModel.players(for: "FWD"))
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .onAppear { viewModel.load() }
        .ignoresSafeArea(edges: .top)
    }

    private func squadSection(title: String, limit: Int, players: [FantasyPlayer]) -> some View {
        KPCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color(hex: "#0A1628"))
                    Spacer()
                    Text("\(players.count)/\(limit)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(players.enumerated()), id: \.offset) { _, player in
                        FantasyPlayerCard(player: player)
                    }
                    if players.count < limit {
                        ForEach(players.count..<limit, id: \.self) { _ in
                            FantasyEmptySlot(title: "Add Player", onAdd: onAddPlayer)
                        }
                    }
                }
            }
        }
    }
}
