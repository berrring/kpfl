//
//  DTO+Mapping.swift
//  KPFL
//
//  Created by Аяз on 27/2/26.
//

import Foundation

extension ClubDTO {
    func toModel() -> Club {
        let color: String
        if let raw = primaryColorHex, raw.hasPrefix("#") {
            color = raw
        } else {
            color = "#0A1628"
        }

        return Club(
            id: String(id),
            name: name,
            shortName: shortName,
            city: city,
            founded: founded ?? 0,
            stadium: stadium ?? "Unknown stadium",
            capacity: capacity ?? 0,
            primaryColorHex: color
        )
    }
}

extension PlayerDTO {
    func toModel() -> Player {
        let pos = position.flatMap { PlayerPosition(rawValue: $0.uppercased()) }

        return .init(
            id: String(id),
            clubId: String(clubId ?? 0),
            firstName: firstName,
            lastName: lastName,
            number: number ?? 0,
            position: pos,
            isCoach: isCoach ?? false,
            nationality: nationality ?? "Unknown",
            birthDateISO: birthDateISO ?? "",
            height: height,
            weight: weight
        )
    }
}

extension MatchDTO {
    func toModel() -> Match {
        let normalized = status.uppercased()
        let mappedStatus: MatchStatus
        switch normalized {
        case "LIVE":
            mappedStatus = .live
        case "FINISHED", "FINAL":
            mappedStatus = .final
        default:
            mappedStatus = .scheduled
        }

        return Match(
            id: String(id),
            dateISO: dateISO,
            time: time,
            round: round ?? 0,
            stadium: stadium ?? "TBD",
            attendance: attendance,
            status: mappedStatus,
            minute: minute,
            homeClubId: String(homeClubId ?? 0),
            awayClubId: String(awayClubId ?? 0),
            homeScore: homeScore,
            awayScore: awayScore
        )
    }
}

extension StandingDTO {
    func toModel() -> Standing {
        return Standing(
            clubId: String(clubId),
            played: played,
            won: won,
            drawn: drawn,
            lost: lost,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
            points: points,
            form: form ?? []
        )
    }
}

extension NewsDTO {
    func toModel() -> NewsItem {
        let normalizedTag = tag.uppercased()
        let mappedTag: NewsTag
        switch normalizedTag {
        case "TRANSFER":
            mappedTag = .Transfer
        case "MATCHDAY":
            mappedTag = .Matchday
        case "INJURY":
            mappedTag = .Injury
        case "OFFICIAL":
            mappedTag = .League
        case "CLUB":
            mappedTag = .Club
        case "INTERVIEW":
            mappedTag = .Interview
        default:
            mappedTag = .League
        }

        let normalizedSummary = summary.isEmpty ? title : summary
        let clubIdString: String? = clubId.map { String($0) }

        return NewsItem(
            id: String(id),
            title: title,
            summary: normalizedSummary,
            dateISO: dateISO,
            tag: mappedTag,
            author: author,
            clubId: clubIdString,
            content: content
        )
    }
}

extension MatchEventDTO {
    func toModel() -> MatchEvent {
        return MatchEvent(
            id: id,
            matchId: matchId,
            minute: minute,
            clubId: clubId,
            // ИСПРАВЛЕНО: EventType вместо MatchEvent.EventType
            type: EventType(rawValue: type) ?? .GOAL,
            // ИСПРАВЛЕНО:playerId теперь String (не опционал)
            playerId: playerId ?? "",
            assistPlayerId: assistPlayerId
        )
    }
}

extension ChampionDTO {
    func toModel() -> ChampionSeason {
        return ChampionSeason(
            id: String(id),
            seasonYear: seasonYear,
            champion: champion,
            championTitleNo: championTitleNo,
            runnerUp: runnerUp,
            thirdPlace: thirdPlace,
            topScorer: topScorer,
            topScorerGoals: topScorerGoals,
            topScorerClub: topScorerClub,
            playerOfYear: playerOfYear,
            notes: notes
        )
    }
}

extension ClubHonourDTO {
    func toModel() -> ClubHonour {
        return ClubHonour(
            id: String(id),
            clubName: clubName,
            titles: titles,
            runnerUpCount: runnerUpCount,
            thirdPlaceCount: thirdPlaceCount,
            championshipYears: championshipYears
        )
    }
}
extension TopScorerDTO {
    func toModel() -> TopScorerEntry {
        return TopScorerEntry(
            id: String(id),
            rankNo: rankNo,
            playerName: playerName,
            positionName: positionName,
            goals: goals,
            matchesPlayed: matchesPlayed,
            goalsPerMatch: goalsPerMatch,
            sourceNote: sourceNote
        )
    }
}

extension TopAppearanceDTO {
    func toModel() -> TopAppearanceEntry {
        return TopAppearanceEntry(
            id: String(id),
            rankNo: rankNo,
            playerName: playerName,
            positionName: positionName,
            matchesPlayed: matchesPlayed,
            goals: goals,
            sourceNote: sourceNote
        )
    }
}

extension HistoryRecordDTO {
    func toModel() -> HistoryRecord {
        return HistoryRecord(
            id: String(id),
            recordKey: recordKey,
            recordValue: recordValue,
            sourceNote: sourceNote
        )
    }
}

