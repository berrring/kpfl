//
//  PlayersSelectionView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI
import Foundation

struct PlayersSelectionView: View {
    @StateObject private var viewModel = PlayerSelectionViewModel()

    let onBack: () -> Void
    let onPlayerAdded: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Select Players", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    filterCard

                    if viewModel.isLoading && viewModel.filteredPlayers().isEmpty {
                        KPCard {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading players...")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if !viewModel.isLoading && viewModel.filteredPlayers().isEmpty {
                        KPCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Players not found")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(Color(hex: "#0A1628"))
                                Text("Сбрось фильтры или открой экран снова.")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                                Button {
                                    viewModel.selectedPosition = "All"
                                    viewModel.selectedClub = "All"
                                    viewModel.sortOption = .points
                                    viewModel.load()
                                } label: {
                                    Text("Reset Filters")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#0A1628"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    ForEach(viewModel.filteredPlayers()) { player in
                        KPCard {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.black.opacity(0.06))
                                    .frame(width: 46, height: 46)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(Color(hex: "#0A1628"))
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.name)
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundStyle(Color(hex: "#0A1628"))
                                    Text("\(player.club) • \(player.position)")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.gray)
                                    Text("$\(String(format: "%.1f", player.price))M • \(player.totalPoints) pts")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.gray)
                                }

                                Spacer()

                                Button {
                                    if viewModel.addPlayer(player) {
                                        onPlayerAdded()
                                    }
                                } label: {
                                    Text("Add")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#0A1628"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
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
        .alert(item: Binding(
            get: { viewModel.alertMessage.map { AlertMessage(text: $0) } },
            set: { _ in viewModel.alertMessage = nil }
        )) { item in
            Alert(title: Text(item.text))
        }
        .ignoresSafeArea(edges: .top)
    }

    private var headerCard: some View {
        KPCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Budget Left")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("$\(String(format: "%.1f", viewModel.team?.budget ?? 100.0))M")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color(hex: "#0A1628"))
                }
                HStack {
                    Text("Squad Size")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("\(viewModel.team?.players.count ?? 0)/15")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color(hex: "#0A1628"))
                }
            }
        }
    }

    private var filterCard: some View {
        KPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Filters")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.gray)

                Picker("Position", selection: $viewModel.selectedPosition) {
                    Text("All").tag("All")
                    Text("GK").tag("GK")
                    Text("DEF").tag("DEF")
                    Text("MID").tag("MID")
                    Text("FWD").tag("FWD")
                }
                .pickerStyle(.segmented)

                Picker("Club", selection: $viewModel.selectedClub) {
                    ForEach(viewModel.clubs, id: \.self) { club in
                        Text(club).tag(club)
                    }
                }
                .pickerStyle(.menu)

                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(PlayerSelectionViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

private struct AlertMessage: Identifiable {
    let id = UUID()
    let text: String
}
