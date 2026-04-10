//
//  FantasyHomeView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct FantasyHomeView: View {
    @StateObject private var viewModel = FantasyHomeViewModel()

    let showBack: Bool
    let onBack: () -> Void
    let onManageTeam: () -> Void
    let onCreateTeam: () -> Void
    let onJoinLeague: () -> Void
    let onCreateLeague: () -> Void
    let onOpenGameweek: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Fantasy", showBack: showBack, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("KPFL Fantasy")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))
                            Text(viewModel.seasonLabel)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                            Text("Current Gameweek: \(viewModel.gameweekLabel)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Team")
                                .font(.system(size: 14, weight: .black))
                            Text(viewModel.hasTeam ? "Team ready" : "Create your squad")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                            Button {
                                if viewModel.hasTeam {
                                    onManageTeam()
                                } else {
                                    onCreateTeam()
                                }
                            } label: {
                                Text("Manage Team")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#0A1628"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("League")
                                .font(.system(size: 14, weight: .black))
                            Text("Join or create your league")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                            HStack(spacing: 10) {
                                Button(action: onJoinLeague) {
                                    Text("Join League")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(Color(hex: "#0A1628"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.06))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                Button(action: onCreateLeague) {
                                    Text("Create League")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "#0A1628"))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Points")
                                .font(.system(size: 14, weight: .black))
                            HStack(spacing: 10) {
                                FantasyStatCard(title: "Total Points", value: viewModel.totalPointsText(), subtitle: "Season")
                                FantasyStatCard(title: "Gameweek Points", value: viewModel.gameweekPointsText(), subtitle: "This week")
                            }
                            Button(action: onOpenGameweek) {
                                Text("View Gameweek")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(Color(hex: "#0A1628"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.black.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .onAppear {
            viewModel.load()
        }
        .ignoresSafeArea(edges: .top)
    }
}
