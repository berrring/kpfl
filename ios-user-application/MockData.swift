//
//  MockData.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

//import Foundation
//
//enum MockData {
//    static let clubs: [Club] = [
//        .init(id: "alai", name: "FC Alai", shortName: "ALAI", city: "Osh", founded: 1958, stadium: "Osh Arena", capacity: 12000, primaryColorHex: "#0A1628"),
//        .init(id: "dordoi", name: "FC Dordoi", shortName: "DOR", city: "Bishkek", founded: 1997, stadium: "Dordoi Stadium", capacity: 8000, primaryColorHex: "#1D4ED8"),
//        .init(id: "abdysh", name: "Abdysh-Ata", shortName: "ABA", city: "Kant", founded: 1992, stadium: "Kant Arena", capacity: 6000, primaryColorHex: "#E8A912"),
//        .init(id: "neftchi", name: "Neftchi", shortName: "NEF", city: "Kochkor-Ata", founded: 2010, stadium: "Neftchi Arena", capacity: 5000, primaryColorHex: "#DC2626")
//    ]
//
//    static let players: [Player] = [
//        .init(id: "p1", clubId: "alai", firstName: "Aziret", lastName: "Uulu", number: 9, position: .FW, isCoach: false, nationality: "Kyrgyzstan", birthDateISO: "2002-02-12", height: 178, weight: 72),
//        .init(id: "p2", clubId: "alai", firstName: "Bek", lastName: "Sadykov", number: 10, position: .MF, isCoach: false, nationality: "Kyrgyzstan", birthDateISO: "2001-08-01", height: 176, weight: 70),
//        .init(id: "p3", clubId: "dordoi", firstName: "Almaz", lastName: "Kadyrov", number: 7, position: .FW, isCoach: false, nationality: "Kazakhstan", birthDateISO: "2000-05-10", height: 180, weight: 75),
//        .init(id: "c1", clubId: "alai", firstName: "Murat", lastName: "Coach", number: 0, position: nil, isCoach: true, nationality: "Kyrgyzstan", birthDateISO: "1975-03-20", height: nil, weight: nil)
//    ]
//
//    static let matches: [Match] = [
//        .init(id: "m1", dateISO: "2026-02-15", time: "18:00", round: 1, stadium: "Osh Arena", attendance: 8200, status: .scheduled, minute: nil, homeClubId: "alai", awayClubId: "dordoi", homeScore: 0, awayScore: 0),
//        .init(id: "m2", dateISO: "2026-02-10", time: "17:00", round: 0, stadium: "Kant Arena", attendance: 4300, status: .final, minute: nil, homeClubId: "abdysh", awayClubId: "neftchi", homeScore: 2, awayScore: 1),
//        .init(id: "m3", dateISO: "2026-02-12", time: "16:30", round: 0, stadium: "Dordoi Stadium", attendance: 5100, status: .live, minute: 63, homeClubId: "dordoi", awayClubId: "alai", homeScore: 1, awayScore: 1)
//    ]
//
//    static let standings: [Standing] = [
//        .init(clubId: "abdysh", played: 1, won: 1, drawn: 0, lost: 0, goalsFor: 2, goalsAgainst: 1, points: 3, form: ["W"]),
//        .init(clubId: "dordoi", played: 1, won: 0, drawn: 1, lost: 0, goalsFor: 1, goalsAgainst: 1, points: 1, form: ["D"]),
//        .init(clubId: "alai", played: 1, won: 0, drawn: 1, lost: 0, goalsFor: 1, goalsAgainst: 1, points: 1, form: ["D"]),
//        .init(clubId: "neftchi", played: 1, won: 0, drawn: 0, lost: 1, goalsFor: 1, goalsAgainst: 2, points: 0, form: ["L"])
//    ]
//
//    static let news: [NewsItem] = [
//        .init(id: "n1", title: "KPFL Season 2026 Kicks Off", summary: "The new season starts with big expectations and packed stadiums.", dateISO: "2026-02-11", tag: .League, author: "KPFL Media", clubId: nil, content: [
//            "The KPFL season begins this week with several headline fixtures.",
//            "Fans can expect updated match coverage and improved stats tracking."
//        ]),
//        .init(id: "n2", title: "FC Alai signs a new midfielder", summary: "A young talent joins the squad ahead of Round 1.", dateISO: "2026-02-09", tag: .Transfer, author: "Club Press", clubId: "alai", content: [
//            "The club announced the signing after successful medical checks.",
//            "The player will be available for selection immediately."
//        ])
//    ]
//
//    static let matchEvents: [MatchEvent] = [
//        .init(id: "e1", matchId: "m3", minute: 12, clubId: "dordoi", type: .GOAL, playerId: "p3", assistPlayerId: nil),
//        .init(id: "e2", matchId: "m3", minute: 40, clubId: "alai", type: .GOAL, playerId: "p1", assistPlayerId: "p2"),
//        .init(id: "e3", matchId: "m3", minute: 55, clubId: "alai", type: .YELLOW, playerId: "p2", assistPlayerId: nil)
//    ]
//}
