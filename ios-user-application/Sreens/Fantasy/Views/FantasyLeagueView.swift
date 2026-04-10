//
//  FantasyLeagueView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct FantasyLeagueView: View {
    @StateObject private var viewModel = LeagueViewModel()

    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "League", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    if let message = viewModel.message {
                        KPCard {
                            Text(message)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    KPCard {
                        HStack {
                            Text("Rank")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.gray)
                                .frame(width: 40, alignment: .leading)
                            Text("Team")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.gray)
                            Spacer()
                            Text("Pts")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                    }

                    if viewModel.isLoading {
                        KPCard {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading leagues...")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else if viewModel.entries.isEmpty {
                        KPCard {
                            Text("No entries yet")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        ForEach(Array(viewModel.entries.enumerated()), id: \.offset) { _, entry in
                            KPCard {
                                HStack {
                                    Text("\(entry.rank)")
                                        .font(.system(size: 12, weight: .black))
                                        .frame(width: 40, alignment: .leading)
                                        .foregroundStyle(Color(hex: "#0A1628"))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.teamName)
                                            .font(.system(size: 13, weight: .black))
                                            .foregroundStyle(Color(hex: "#0A1628"))
                                        Text(entry.username)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.gray)
                                    }
                                    Spacer()
                                    Text("\(entry.totalPoints)")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(Color(hex: "#0A1628"))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .onAppear { viewModel.load() }
        .ignoresSafeArea(edges: .top)
    }
}
