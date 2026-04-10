//
//  CreateTeamView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct CreateTeamView: View {
    @StateObject private var viewModel = CreateTeamViewModel()

    let onBack: () -> Void
    let onCreated: () -> Void

    private let logoColors: [Color] = [
        Color(hex: "#0A1628"),
        Color(hex: "#E8A912"),
        Color(hex: "#1D4ED8"),
        Color(hex: "#DC2626"),
        Color(hex: "#16A34A"),
        Color(hex: "#7C3AED")
    ]

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Create Team", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Team Name")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray)
                            TextField("Enter team name", text: $viewModel.teamName)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(12)
                                .background(Color.black.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }

                    KPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Logo")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(0..<logoColors.count, id: \.self) { index in
                                    Button {
                                        viewModel.selectedLogoIndex = index
                                    } label: {
                                        Circle()
                                            .fill(logoColors[index])
                                            .frame(height: 56)
                                            .overlay(
                                                Image(systemName: "shield.fill")
                                                    .font(.system(size: 18, weight: .black))
                                                    .foregroundStyle(.white)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: viewModel.selectedLogoIndex == index ? 3 : 0)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    Button {
                        if viewModel.createTeam() {
                            onCreated()
                        }
                    } label: {
                        Text("Create Team")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "#0A1628"))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .alert(item: Binding(
            get: { viewModel.alertMessage.map { AlertMessage(text: $0) } },
            set: { _ in viewModel.alertMessage = nil }
        )) { item in
            Alert(title: Text(item.text))
        }
        .ignoresSafeArea(edges: .top)
    }
}

private struct AlertMessage: Identifiable {
    let id = UUID()
    let text: String
}
