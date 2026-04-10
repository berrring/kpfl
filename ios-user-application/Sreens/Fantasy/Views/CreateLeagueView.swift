//
//  CreateLeagueView.swift
//  KPFL
//
//  Created by Codex on 9/4/26.
//

import SwiftUI

struct CreateLeagueView: View {
    @State private var leagueName = ""
    @State private var isLoading = false
    @State private var message: String?

    private let api = KPFLAPI.shared

    let onBack: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Create League", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("League Name")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))

                            TextField("Enter league name", text: $leagueName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .padding(10)
                                .background(Color.black.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Button {
                                create()
                            } label: {
                                Text(isLoading ? "Creating..." : "Create")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "#0A1628"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .disabled(isLoading)
                        }
                    }

                    if let message {
                        KPCard {
                            Text(message)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
    }

    private func create() {
        let trimmed = leagueName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            message = "Введите название лиги."
            return
        }

        isLoading = true
        Task {
            do {
                _ = try await api.fantasyCreateLeague(name: trimmed)
                await MainActor.run {
                    isLoading = false
                    message = "Лига создана."
                    onDone()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    message = "Ошибка: \(error.localizedDescription)"
                }
            }
        }
    }
}
