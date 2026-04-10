//
//  ClubsScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct ClubsScreen: View {
    @EnvironmentObject private var store: DataStore
    let onClub: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Clubs")

            Group {
                switch store.loadState {
                case .idle, .loading:
                    ProgressView().padding(.top, 30)

                case .failed(let message):
                    VStack(spacing: 10) {
                        Text("Failed to load clubs")
                            .font(.system(size: 14, weight: .black))
                        Text(message)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.gray)
                        Button {
                            Task { await store.refreshAll() }
                        } label: {
                            Text("Try again")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12).padding(.vertical, 10)
                                .background(Color(hex: "#0A1628"))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 30)

                case .loaded:
                    ScrollView {
                        VStack(spacing: 14) {
                            KPCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("KPFL Clubs")
                                        .font(.system(size: 16, weight: .black))
                                    Text("\(store.clubs.count) clubs competing in the 2026 season")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.gray)
                                }
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Array(store.clubs.enumerated()), id: \.offset) { _, club in
                                    ClubGridCard(club: club) { onClub(club.id) }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 90)
                    }
                }
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
        .task {
            await store.loadAllIfNeeded()
        }
        .refreshable {
            await store.refreshAll()
        }
    }
}

struct ClubGridCard: View {
    @EnvironmentObject private var store: DataStore
    let club: Club
    let onTap: () -> Void

    private var standing: Standing? { store.standings.first { $0.clubId == club.id } }
    private var position: Int { (store.standings.firstIndex { $0.clubId == club.id } ?? 0) + 1 }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(colors: [Color(hex: club.primaryColorHex), Color(hex: club.primaryColorHex).opacity(0.75)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    ClubBadge(club: club, size: 56, ring: true)

                    Text("#\(position)")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(position <= 3 ? Color(hex: "#0A1628") : .white)
                        .padding(.horizontal, 8).padding(.vertical, 6)
                        .background {
                            if position <= 3 {
                                LinearGradient(colors: [Color(hex: "#F5C742"), Color(hex: "#E8A912")],
                                               startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.black.opacity(0.25)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(10)
                }
                .frame(height: 96)

                VStack(alignment: .leading, spacing: 6) {
                    Text(club.name)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(.black)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(club.city)
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.gray)

                    HStack {
                        if let s = standing {
                            HStack(spacing: 6) {
                                Text("\(s.won)W").foregroundStyle(.green).fontWeight(.bold)
                                Text("-").foregroundStyle(.gray.opacity(0.6))
                                Text("\(s.drawn)D").foregroundStyle(.gray)
                                Text("-").foregroundStyle(.gray.opacity(0.6))
                                Text("\(s.lost)L").foregroundStyle(.red).fontWeight(.bold)
                            }
                            .font(.system(size: 11, weight: .semibold))

                            Spacer()

                            Text("\(s.points) pts")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(Color(hex: "#C98F00"))
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color(hex: "#E8A912").opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else {
                            Spacer()
                            Text("—")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(12)
                .background(.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}
