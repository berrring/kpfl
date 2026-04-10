//
//  JoinLeagueView.swift
//  KPFL
//
//  Created by Codex on 9/4/26.
//

import SwiftUI

struct JoinLeagueView: View {
    @State private var code = ""
    @State private var isLoading = false
    @State private var message: String?

    private let api = KPFLAPI.shared

    let onBack: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "Join League", showBack: true, onBack: onBack)

            ScrollView {
                VStack(spacing: 14) {
                    KPCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("League Code")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Color(hex: "#0A1628"))

                            TextField("Enter code", text: $code)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(10)
                                .background(Color.black.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Button {
                                join()
                            } label: {
                                Text(isLoading ? "Joining..." : "Join")
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

    private func join() {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            message = "Введите код лиги."
            return
        }

        isLoading = true
        Task {
            do {
                _ = try await api.fantasyJoinLeague(code: trimmed)
                await MainActor.run {
                    isLoading = false
                    message = "Успешно вступили в лигу."
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
