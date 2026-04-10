//
//  PlayerProfileScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct PlayerProfileScreen: View {
    @EnvironmentObject private var store: DataStore
    let playerId: String
    let onBack: () -> Void
    let onClub: (String) -> Void

    var body: some View {
        if let player = store.player(playerId),
           let club = store.club(player.clubId) {
            VStack(spacing: 0) {
                MobileHeader(title: "Player", showBack: true, onBack: onBack)

                hero(player: player, club: club)

                ScrollView {
                    VStack(spacing: 14) {
                        personalInfo(player: player, club: club)

                        if !player.isCoach {
                            seasonStats(player: player)
                        } else {
                            KPCard {
                                VStack(spacing: 10) {
                                    Text("👔").font(.system(size: 34))
                                    Text("Coaching Staff")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Detailed coaching statistics coming soon")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 24)
                }
                .background(Color.appBackground)
            }
            .ignoresSafeArea(edges: .top)
        } else {
            VStack {
                MobileHeader(title: "Player", showBack: true, onBack: onBack)
                Spacer()
                Text("Player not found").foregroundStyle(.gray)
                Spacer()
            }
            .background(Color.appBackground)
        }
    }

    private func hero(player: Player, club: Club) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: club.primaryColorHex), Color(hex: club.primaryColorHex).opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 10) {
                if player.isCoach {
                    Circle().fill(.black.opacity(0.25)).frame(width: 92, height: 92)
                        .overlay(Image(systemName: "person.fill").font(.system(size: 38, weight: .bold)).foregroundStyle(.white))
                } else {
                    Circle().fill(.black.opacity(0.25)).frame(width: 92, height: 92)
                        .overlay(Text("\(player.number)").font(.system(size: 38, weight: .black)).foregroundStyle(.white))
                }

                Text("\(player.firstName) \(player.lastName)")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)

                if player.isCoach {
                    Text("Head Coach")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else if let pos = player.position {
                    Text(positionLabel(pos))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(positionColor(pos))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(14)

            Button {
                onClub(club.id)
            } label: {
                HStack(spacing: 8) {
                    ClubBadge(club: club, size: 26)
                    Text(club.shortName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(14)
        }
        .frame(height: 240)
    }

    private func personalInfo(player: Player, club: Club) -> some View {
        let age = DateFmt.age(birthISO: player.birthDateISO)

        return KPCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Personal Information")
                    .font(.system(size: 14, weight: .black))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    infoTile(title: "Full Name", value: "\(player.firstName) \(player.lastName)")
                    if !player.isCoach { infoTile(title: "Shirt Number", value: "#\(player.number)") }
                    if let pos = player.position, !player.isCoach { infoTile(title: "Position", value: positionLabel(pos)) }
                    infoTile(title: "Nationality", value: player.nationality)
                    infoTile(title: "Date of Birth", value: player.birthDateISO)
                    infoTile(title: "Age", value: "\(age) years")
                    if let h = player.height, !player.isCoach { infoTile(title: "Height", value: "\(h) cm") }
                    if let w = player.weight, !player.isCoach { infoTile(title: "Weight", value: "\(w) kg") }

                    Button {
                        onClub(club.id)
                    } label: {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Club")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.gray)
                                HStack(spacing: 8) {
                                    ClubBadge(club: club, size: 18)
                                    Text(club.name)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.black)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray.opacity(0.6))
                        }
                        .padding(10)
                        .background(Color.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func seasonStats(player: Player) -> some View {
        let goals = store.events.filter { $0.type == .GOAL && $0.playerId == player.id }.count
        let assists = store.events.filter { $0.assistPlayerId == player.id }.count
        let yellows = store.events.filter { $0.type == .YELLOW && $0.playerId == player.id }.count
        let reds = store.events.filter { $0.type == .RED && $0.playerId == player.id }.count

        return KPCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Season 2026 Statistics")
                        .font(.system(size: 14, weight: .black))
                    Spacer()
                    Text("From match events")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    statTile(icon: "⚽", value: "\(goals)", label: "Goals")
                    statTile(icon: "👟", value: "\(assists)", label: "Assists")
                    statTile(icon: "🟨", value: "\(yellows)", label: "Yellows")
                    statTile(icon: "🟥", value: "\(reds)", label: "Reds")
                }
            }
        }
    }

    private func infoTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(icon).font(.system(size: 22))
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(.black)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func positionLabel(_ pos: PlayerPosition) -> String {
        switch pos {
        case .GK: return "Goalkeeper"
        case .DF: return "Defender"
        case .MF: return "Midfielder"
        case .FW: return "Forward"
        }
    }

    private func positionColor(_ pos: PlayerPosition) -> Color {
        switch pos {
        case .GK: return .yellow
        case .DF: return .blue
        case .MF: return .green
        case .FW: return .red
        }
    }
}
