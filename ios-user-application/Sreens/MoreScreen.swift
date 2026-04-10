//
//  MoreScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct MoreScreen: View {
    @EnvironmentObject private var store: DataStore
    let onNews: () -> Void
    let onFantasy: () -> Void
    let onSettings: () -> Void
    let onAuth: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "More")
            ScrollView {
                VStack(spacing: 12) {
                    if store.isSignedIn {
                        let name = store.userName
                        KPCard {
                            HStack(spacing: 12) {
                                Circle().fill(Color(hex: "#F5A623")).frame(width: 56, height: 56)
                                    .overlay(Text(String(name.prefix(1)).uppercased()).font(.system(size: 22, weight: .black)).foregroundStyle(.white))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(name).font(.system(size: 14, weight: .black))
                                    Text("KPFL Member").font(.system(size: 12, weight: .semibold)).foregroundStyle(.gray)
                                }
                                Spacer()
                                Button("Sign Out") { store.signOut() }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.red)
                            }
                        }
                    } else {
                        Button {
                            onAuth()
                        } label: {
                            KPCard {
                                HStack(spacing: 12) {
                                    Circle().fill(Color(hex: "#F5A623")).frame(width: 56, height: 56)
                                        .overlay(Image(systemName: "person.fill").font(.system(size: 20, weight: .bold)).foregroundStyle(.white))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sign In").font(.system(size: 14, weight: .black)).foregroundStyle(.black)
                                        Text("Access your account").font(.system(size: 12, weight: .semibold)).foregroundStyle(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.gray.opacity(0.6))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(spacing: 10) {
                        menuRow(icon: "📰", title: "News", subtitle: "Latest updates and articles", action: onNews, badge: nil)
                        menuRow(icon: "⚽", title: "Fantasy League", subtitle: "Create your dream team", action: onFantasy, badge: nil)
                        menuRow(icon: "gearshape.fill", title: "Settings", subtitle: "App preferences", action: onSettings, badge: nil)
                    }

                    KPCard {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(hex: "#F5A623"))
                                Text("KPFL")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)

                            Text("Kyrgyz Professional Football League")
                                .font(.system(size: 13, weight: .bold))
                            Text("Version 1.0.0 MVP")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.gray)
                            Text("© 2026 KPFL. All rights reserved.")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.gray.opacity(0.75))
                                .padding(.top, 6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 90)
            }
            .background(Color.appBackground)
        }
        .ignoresSafeArea(edges: .top)
    }

    private func menuRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void, badge: String?, disabled: Bool = false) -> some View {
        Button(action: action) {
            KPCard {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.05))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Group {
                                if icon.hasPrefix("gear") {
                                    Image(systemName: icon).foregroundStyle(.gray)
                                } else {
                                    Text(icon).font(.system(size: 24))
                                }
                            }
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(disabled ? .gray : .black)
                            if let badge {
                                Text(badge)
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(Color(hex: "#F5A623"))
                                    .padding(.horizontal, 8).padding(.vertical, 5)
                                    .background(Color(hex: "#F5A623").opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.gray)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray.opacity(0.6))
                }
                .opacity(disabled ? 0.55 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}
