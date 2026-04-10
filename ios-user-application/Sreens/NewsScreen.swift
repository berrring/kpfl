//
//  NewsScreen.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct NewsScreen: View {
    @EnvironmentObject private var store: DataStore
    let onBack: () -> Void
    let onSelect: (String) -> Void

    enum Filter: String, CaseIterable {
        case all = "All"
        case Transfer, Matchday, Club, League, Injury, Interview

        var tag: NewsTag? {
            switch self {
            case .all: return nil
            default: return NewsTag(rawValue: self.rawValue)
            }
        }
    }

    @State private var filter: Filter = .all

    private var filtered: [NewsItem] {
        let list = store.news.sorted { $0.dateISO > $1.dateISO }
        guard let tag = filter.tag else { return list }
        return list.filter { $0.tag == tag }
    }

    var body: some View {
        VStack(spacing: 0) {
            MobileHeader(title: "News", showBack: true, onBack: onBack)

            filterBar
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.appBackground)

            ScrollView {
                VStack(spacing: 14) {
                    if filter == .all, let first = filtered.first {
                        NewsHeroCard(item: first, onTap: { onSelect(first.id) })
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Array((filter == .all ? Array(filtered.dropFirst()) : filtered).enumerated()), id: \.offset) { _, item in
                            NewsGridCard(item: item, onTap: { onSelect(item.id) })
                        }
                    }

                    if filtered.isEmpty {
                        KPCard {
                            VStack(spacing: 10) {
                                Text("📰").font(.system(size: 34))
                                Text("No news found").font(.system(size: 14, weight: .bold))
                                Text("Try selecting a different category")
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
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Filter.allCases, id: \.self) { t in
                    Button {
                        filter = t
                    } label: {
                        Text(t.rawValue)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(filter == t ? .white : .gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(filter == t ? Color(hex: "#0A1628") : .white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct NewsHeroCard: View {
    let item: NewsItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.08))

                LinearGradient(colors: [TagColor.color(item.tag).opacity(0.25), .black.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    TagBadge(text: item.tag.rawValue, color: TagColor.color(item.tag))
                    Text(item.title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                    Text(item.summary)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                    Text(DateFmt.short(item.dateISO))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(14)
            }
            .frame(height: 190)
        }
        .buttonStyle(.plain)
    }
}

struct NewsGridCard: View {
    let item: NewsItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            KPCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        TagBadge(text: item.tag.rawValue, color: TagColor.color(item.tag))
                        Spacer()
                        Text(DateFmt.short(item.dateISO))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                    Text(item.title)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(.black)
                        .lineLimit(3)
                    Text(item.summary)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.gray)
                        .lineLimit(3)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct NewsCompactRow: View {
    let item: NewsItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(TagColor.color(item.tag).opacity(0.18))
                    .frame(width: 54, height: 54)
                    .overlay(Text("⚽").opacity(0.6))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TagBadge(text: item.tag.rawValue, color: TagColor.color(item.tag))
                        Spacer()
                        Text(DateFmt.short(item.dateISO))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                    Text(item.title)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
