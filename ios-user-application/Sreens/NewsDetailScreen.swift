//
//  NewsDetailScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct NewsDetailScreen: View {
    @EnvironmentObject private var store: DataStore
    let newsId: String
    let onBack: () -> Void

    var body: some View {
        if let item = store.news.first(where: { $0.id == newsId }) {
            let club = item.clubId.flatMap { store.club($0) }
            let bg = club?.primaryColorHex ?? "#0A1628"

            VStack(spacing: 0) {
                MobileHeader(title: "News", showBack: true, onBack: onBack)

                ZStack(alignment: .bottomLeading) {
                    Color(hex: bg)
                    Text(club != nil ? club!.shortName : "⚽")
                        .font(.system(size: 70, weight: .black))
                        .foregroundStyle(.white.opacity(0.14))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    LinearGradient(colors: [.black.opacity(0.85), .black.opacity(0.2)], startPoint: .bottom, endPoint: .top)
                    VStack(alignment: .leading, spacing: 10) {
                        TagBadge(text: item.tag.rawValue, color: TagColor.color(item.tag))
                        Text(item.title)
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(4)
                    }
                    .padding(14)
                }
                .frame(height: 220)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Text(DateFmt.short(item.dateISO))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray)
                            if let a = item.author {
                                Text("•").foregroundStyle(.gray)
                                Text("By \(a)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.gray)
                            }
                        }

                        Text(item.summary)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.75))

                        ForEach(Array(item.content.enumerated()), id: \.offset) { _, p in
                            Text(p)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.black.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        KPCard {
                            HStack {
                                Text("Share this article")
                                    .font(.system(size: 13, weight: .bold))
                                Spacer()
                                Button { UIPasteboard.general.string = item.title } label: {
                                    Text("📋").font(.system(size: 18))
                                }.buttonStyle(.plain)
                                Button { } label: {
                                    Text("📧").font(.system(size: 18))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(14)
                    .padding(.bottom, 24)
                }
                .background(Color.appBackground)
            }
            .ignoresSafeArea(edges: .top)
        } else {
            VStack {
                MobileHeader(title: "News", showBack: true, onBack: onBack)
                Spacer()
                Text("Article not found").foregroundStyle(.gray)
                Spacer()
            }
            .background(Color.appBackground)
        }
    }
}
