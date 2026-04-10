//
//  StandingScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct StandingsScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var selectedSeasonYear: Int?
    let onClub: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Standings")
            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("League Standings")
                                .font(.system(size: 16, weight: .black))
                            Text("KPFL Season 2026 • Updated after each matchday")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                    }

                    if !store.champions.isEmpty {
                        KPCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Season Champion")
                                        .font(.system(size: 14, weight: .black))
                                    Spacer()
                                    seasonPicker
                                }

                                if let year = selectedSeasonYear,
                                   let champ = store.champion(for: year) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "trophy.fill")
                                            .font(.system(size: 14, weight: .black))
                                            .foregroundStyle(Color(hex: "#E8A912"))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(champ.champion) • \(year)")
                                                .font(.system(size: 13, weight: .bold))
                                            if let runner = champ.runnerUp, !runner.isEmpty {
                                                Text("Runner-up: \(runner)")
                                                    .font(.system(size: 11, weight: .semibold))
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                        Spacer()
                                        if let titles = champ.championTitleNo {
                                            Text("#\(titles)")
                                                .font(.system(size: 12, weight: .black))
                                                .foregroundStyle(Color(hex: "#0A1628"))
                                        }
                                    }
                                } else {
                                    Text("Champion data is not available for this season.")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }

                    KPCard {
                        VStack(spacing: 10) {
                            headerRow
                            Divider().opacity(0.2)
                            ForEach(Array(store.standings.enumerated()), id: \.offset) { idx, s in
                                if let club = store.club(s.clubId) {
                                    Button { onClub(club.id) } label: {
                                        HStack(spacing: 10) {
                                            placeCell(idx + 1)
                                            ClubBadge(club: club, size: 26)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(club.name)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(.black)
                                                    .lineLimit(1)
                                                Text(club.city)
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundStyle(.gray)
                                            }
                                            Spacer()
                                            statCell("\(s.played)")
                                            statCell("\(s.won)", color: .green)
                                            statCell("\(s.drawn)", color: .gray)
                                            statCell("\(s.lost)", color: .red)
                                            Text("\(s.points)")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundStyle(Color(hex: "#C98F00"))
                                                .frame(width: 30, alignment: .trailing)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                Divider().opacity(0.12)
                            }
                            legend
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 90)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
        .onChange(of: store.champions) { _ in
            ensureSeasonSelection()
        }
        .onAppear {
            ensureSeasonSelection()
        }
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            Text("#")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
                .frame(width: 26, alignment: .leading)
            Text("Club")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
            Spacer()
            Text("P").font(.system(size: 10, weight: .bold)).foregroundStyle(.gray).frame(width: 18)
            Text("W").font(.system(size: 10, weight: .bold)).foregroundStyle(.gray).frame(width: 18)
            Text("D").font(.system(size: 10, weight: .bold)).foregroundStyle(.gray).frame(width: 18)
            Text("L").font(.system(size: 10, weight: .bold)).foregroundStyle(.gray).frame(width: 18)
            Text("Pts").font(.system(size: 10, weight: .bold)).foregroundStyle(Color(hex: "#E8A912")).frame(width: 30, alignment: .trailing)
        }
    }

    private func placeCell(_ pos: Int) -> some View {
        Text("\(pos)")
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(pos == 1 ? Color(hex: "#0A1628") : (pos <= 3 ? .white : .gray))
            .frame(width: 26, height: 26)
            .background(
                Group {
                    if pos == 1 {
                        LinearGradient(colors: [Color(hex: "#F5C742"), Color(hex: "#E8A912")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else if pos <= 3 {
                        Color(hex: "#0A1628")
                    } else {
                        Color.appBackground
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func statCell(_ t: String, color: Color = .gray) -> some View {
        Text(t)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 18, alignment: .center)
    }

    private var seasonPicker: some View {
        let seasons = store.champions.map { $0.seasonYear }.sorted(by: >)
        return Menu {
            ForEach(seasons, id: \.self) { year in
                Button("\(year)") {
                    selectedSeasonYear = year
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedSeasonYear.map { "\($0)" } ?? "Select")
                    .font(.system(size: 12, weight: .bold))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(Color(hex: "#0A1628"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func ensureSeasonSelection() {
        if selectedSeasonYear == nil {
            selectedSeasonYear = store.champions.first?.seasonYear
        }
    }

    private var legend: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Circle().fill(.green).frame(width: 8, height: 8)
                Text("Champions League")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            HStack(spacing: 6) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Text("Relegation")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text("Tie-breaker: Points → GD → GF")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.gray.opacity(0.8))
        }
        .padding(.top, 6)
    }
}
