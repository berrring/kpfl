//
//  MatchesScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct MatchesScreen: View {
    @EnvironmentObject private var store: DataStore
    let onMatch: (String) -> Void

    @State private var filter: MatchFilter = .all
    @State private var selectedRound: Int? = nil

    enum MatchFilter: String, CaseIterable {
        case all = "All Matches"
        case results = "Results"
        case upcoming = "Upcoming"
    }

    private var rounds: [Int] {
        Array(Set(store.matches.map { $0.round })).sorted()
    }

    private var filtered: [Match] {
        var m = store.matches
        switch filter {
        case .all: break
        case .results:
            m = m.filter { $0.status == .final || $0.status == .live }
        case .upcoming:
            m = m.filter { $0.status == .scheduled }
        }
        if let r = selectedRound {
            m = m.filter { $0.round == r }
        }
        return m.sorted { ($0.round, $0.dateISO, $0.time) < ($1.round, $1.dateISO, $1.time) }
    }

    private var grouped: [(round: Int, matches: [Match])] {
        let dict = Dictionary(grouping: filtered, by: { $0.round })
        return dict.keys.sorted().map { (round: $0, matches: dict[$0]!.sorted { $0.dateISO < $1.dateISO }) }
    }

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Schedule")
            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ForEach(MatchFilter.allCases, id: \.self) { f in
                                    Button {
                                        filter = f
                                    } label: {
                                        Text(f.rawValue)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(filter == f ? Color(hex: "#0A1628") : Color.appBackground)
                                            .foregroundStyle(filter == f ? .white : Color.gray)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Button {
                                        selectedRound = nil
                                    } label: {
                                        Text("All")
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(selectedRound == nil ? Color(hex: "#E8A912") : Color.appBackground)
                                            .foregroundStyle(selectedRound == nil ? Color(hex: "#0A1628") : .gray)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    .buttonStyle(.plain)

                                    ForEach(rounds, id: \.self) { r in
                                        Button {
                                            selectedRound = r
                                        } label: {
                                            Text("R\(r)")
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 8)
                                                .background(selectedRound == r ? Color(hex: "#E8A912") : Color.appBackground)
                                                .foregroundStyle(selectedRound == r ? Color(hex: "#0A1628") : .gray)
                                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }

                    VStack(spacing: 16) {
                        ForEach(grouped, id: \.round) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#0A1628"))
                                        Text("\(group.round)")
                                            .font(.system(size: 13, weight: .black))
                                            .foregroundStyle(.white)
                                    }
                                    .frame(width: 40, height: 40)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Round \(group.round)")
                                            .font(.system(size: 13, weight: .black))
                                        let done = group.matches.filter { $0.status == .final }.count
                                        let sch = group.matches.filter { $0.status == .scheduled }.count
                                        Text("\(done) completed • \(sch) scheduled")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.gray)
                                    }
                                    Spacer()
                                }

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(Array(group.matches.enumerated()), id: \.offset) { _, m in
                                        MatchCardView(match: m, onTap: { onMatch(m.id) })
                                    }
                                }
                            }
                        }
                    }

                    if grouped.isEmpty {
                        KPCard {
                            VStack(spacing: 10) {
                                Text("⚽").font(.system(size: 34))
                                Text("No matches found")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Try adjusting your filters")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 90)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
    }
}
