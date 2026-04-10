//
//  GameweekView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct GameweekView: View {
    @StateObject private var viewModel = GameweekViewModel()

    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Gameweek", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Current Gameweek")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray)
                            Text(viewModel.currentGameweek)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))
                        }
                    }

                    if viewModel.isLoading {
                        KPCard {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading gameweek data...")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if let message = viewModel.infoMessage {
                        KPCard {
                            Text(message)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Matches")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))
                            if viewModel.matches.isEmpty {
                                Text("No matches")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                            } else {
                                ForEach(viewModel.matches) { match in
                                    HStack(spacing: 10) {
                                        Text(match.home)
                                            .font(.system(size: 12, weight: .bold))
                                            .lineLimit(1)
                                        Text("vs")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.gray)
                                        Text(match.away)
                                            .font(.system(size: 12, weight: .bold))
                                            .lineLimit(1)
                                        Spacer()
                                        Text(match.time)
                                            .font(.system(size: 11, weight: .black))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.06))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Player Points")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))
                            if viewModel.playerPoints.isEmpty {
                                Text("No points yet")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                            } else {
                                ForEach(viewModel.playerPoints) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(.gray)
                                        Spacer()
                                        Text("+\(item.points)")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(Color(hex: "#0A1628"))
                                    }
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
