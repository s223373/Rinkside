//  NHLPlayer.swift
//  Rinkside
//
//  Created by Nik Bar on 12/28/24.
//
import SwiftUI

struct NHLPlayer: Codable, CustomStringConvertible {
    let playerId: Int
    let isActive: Bool
    let currentTeamId: Int?
    let currentTeamAbbrev: String?
    let fullTeamName: NHLType?
    let teamCommonName: NHLType?
    let teamPlaceNameWithPreposition: NHLType?
    let firstName: NHLType
    let lastName: NHLType
    let teamLogo: String?
    let sweaterNumber: Int?
    let position: String
    let headshot: String
    let heroImage: String
    let heightInInches: Int
    let heightInCentimeters: Int
    let weightInPounds: Int
    let weightInKilograms: Int
    let birthDate: String?
    let birthCity: NHLType
    let birthStateProvince: NHLType?
    let birthCountry: String
    let shootsCatches: String
    let draftDetails: NHLDraftDetails?
    let playerSlug: String
    let inTop100AllTime: Int
    let inHHOF: Int
    let featuredStats: NHLPlayerFeaturedStats?
    let careerTotals: NHLPlayerCareerTotals?
    let shopLink: String
    let twitterLink: String
    let watchLink: String
    let last5Games: [NHLGameDetail]
    let seasonTotals: [NHLSeasonTotal]?
    let currentRoster: [NHLPersonShort]?

    var description: String {
        "\(firstName.def) \(lastName.def)"
    }

    func toSkaterStats(value: Double?) -> NHLPlayerSkaterStats? {
        guard let seasonStats = seasonTotals?
                    .filter({ $0.leagueAbbrev == "NHL" })
                    .max(by: { ($0.season ?? 20242025) < ($1.season ?? 20242025) }),
                  let gamesPlayed = seasonStats.gamesPlayed,
                  gamesPlayed >= 25 else {
                return nil
            }

            return NHLPlayerSkaterStats(
                playerId: playerId,
                firstName: firstName,
                lastName: lastName,
                sweaterNumber: sweaterNumber,
                headshot: headshot,
                teamAbbrev: (currentTeamAbbrev) ?? "N/A",
                teamName: fullTeamName ?? NHLType(def: "N/A"),
                teamLogo: (teamLogo) ?? "N/A",
                position: position,
                value: value ?? Double(seasonStats.points ?? 0),
                gamesPlayed: seasonStats.gamesPlayed,
                goals: seasonStats.goals,
                assists: seasonStats.assists,
                points: seasonStats.points,
                plusMinus: seasonStats.plusMinus,
                pim: seasonStats.pim,
                wins: seasonStats.wins,
                losses: seasonStats.losses,
                shutouts: seasonStats.shutouts,
                savePctg: seasonStats.savePctg,
                goalsAgainstAvg: seasonStats.goalsAgainstAvg,
                calculatedRating: nil,
                isOnHotStreak: false
            )
        }
}

struct NHLDraftDetails: Codable, CustomStringConvertible {
    let year: Int
    let teamAbbrev: String
    let round: Int
    let pickInRound: Int
    let overallPick: Int

    var description: String {
        "\(year) \(teamAbbrev) \(round) \(pickInRound) \(overallPick)"
    }
}

struct NHLGameDetail: Codable, CustomStringConvertible {
    let decision: String?
    let gameDate: String
    let gameId: Int
    let gameTypeId: Int
    let gamesStarted: Int?
    let goalsAgainst: Int?
    let homeRoadFlag: String
    let opponentAbbrev: String
    let penaltyMinutes: Int?
    let savePctg: Double?
    let shotsAgainst: Int?
    let teamAbbrev: String
    let toi: String
    let assists: Int?
    let goals: Int?
    let pim: Int?
    let plusMinus: Int?
    let points: Int?
    let powerPlayGoals: Int?
    let shifts: Int?
    let shorthandedGoals: Int?
    let shots: Int?

    var description: String {
        "\(teamAbbrev) vs \(opponentAbbrev)"
    }
}

struct NHLSeasonTotal: Codable, CustomStringConvertible {
    let gameTypeId: Int?
    let gamesPlayed: Int?
    let goalsAgainstAvg: Double?
    let goalsAgainst: Int?
    let leagueAbbrev: String?
    let savePctg: Double?
    let season: Int?
    let sequence: Int?
    let losses: Int?
    let wins: Int?
    let ties: Int?
    let timeOnIce: String?
    let shutouts: Int?
    let teamName: NHLType?
    let assists: Int?
    let goals: Int?
    let points: Int?
    let pim: Int?
    let otLosses: Int?
    let teamPlaceNameWithPreposition: NHLType?
    let plusMinus: Int?
    let gamesStarted: Int?

    var description: String {
        "\(teamName?.def ?? "Unknown") - \(season ?? 0) - \(sequence ?? 0) - \(points ?? 0) - \(goals ?? 0) - \(assists ?? 0)"
    }

    func toSkaterStats(player: NHLPlayer, value: Double?) -> NHLPlayerSkaterStats {
        return NHLPlayerSkaterStats(
            playerId: player.playerId,
            firstName: player.firstName,
            lastName: player.lastName,
            sweaterNumber: player.sweaterNumber,
            headshot: player.headshot,
            teamAbbrev: player.currentTeamAbbrev ?? "",
            teamName: player.fullTeamName ?? NHLType(def: ""),
            teamLogo: player.teamLogo ?? "",
            position: player.position,
            value: value ?? 0.0,
            gamesPlayed: gamesPlayed,
            goals: goals,
            assists: assists,
            points: points,
            plusMinus: plusMinus,
            pim: pim,
            wins: wins,
            losses: losses,
            shutouts: shutouts,
            savePctg: savePctg,
            goalsAgainstAvg: goalsAgainstAvg,
            calculatedRating: nil,
            isOnHotStreak: false
        )
    }
}

struct NHLPersonShort: Codable, CustomStringConvertible {
    let playerId: Int
    let firstName: NHLType
    let lastName: NHLType
    let playerSlug: String

    var description: String {
        "\(firstName.def) \(lastName.def)"
    }
}

struct NHLPlayerSkaterStats: Codable, CustomStringConvertible, Identifiable {
    let playerId: Int
    let firstName: NHLType
    let lastName: NHLType
    let sweaterNumber: Int?
    let headshot: String
    let teamAbbrev: String
    let teamName: NHLType
    let teamLogo: String
    let position: String
    let value: Double
    let gamesPlayed: Int?
    let goals: Int?
    let assists: Int?
    let points: Int?
    let plusMinus: Int?
    let pim: Int?
    let wins: Int?
    let losses: Int?
    let shutouts: Int?
    let savePctg: Double?
    let goalsAgainstAvg: Double?
    var calculatedRating: Int?
    var isOnHotStreak: Bool

    var id: Int { playerId }

    var fullName: String {
        firstName.def + " " + lastName.def
    }

    func toNHLPlayer() -> NHLPlayer {
        let seasonTotal = NHLSeasonTotal(
            gameTypeId: 2,
            gamesPlayed: gamesPlayed,
            goalsAgainstAvg: goalsAgainstAvg,
            goalsAgainst: nil,
            leagueAbbrev: "NHL",
            savePctg: savePctg,
            season: 20242025,
            sequence: 1,
            losses: losses,
            wins: wins,
            ties: nil,
            timeOnIce: nil,
            shutouts: shutouts,
            teamName: teamName,
            assists: assists,
            goals: goals,
            points: points,
            pim: pim,
            otLosses: nil,
            teamPlaceNameWithPreposition: nil,
            plusMinus: plusMinus,
            gamesStarted: nil
        )

        return NHLPlayer(
            playerId: playerId,
            isActive: true,
            currentTeamId: nil,
            currentTeamAbbrev: teamAbbrev,
            fullTeamName: teamName,
            teamCommonName: teamName,
            teamPlaceNameWithPreposition: nil,
            firstName: firstName,
            lastName: lastName,
            teamLogo: teamLogo,
            sweaterNumber: sweaterNumber,
            position: position,
            headshot: headshot,
            heroImage: headshot,
            heightInInches: 0,
            heightInCentimeters: 0,
            weightInPounds: 0,
            weightInKilograms: 0,
            birthDate: nil,
            birthCity: NHLType(def: ""),
            birthStateProvince: nil,
            birthCountry: "",
            shootsCatches: "",
            draftDetails: nil,
            playerSlug: "\(firstName.def.lowercased())-\(lastName.def.lowercased())",
            inTop100AllTime: 0,
            inHHOF: 0,
            featuredStats: nil,
            careerTotals: nil,
            shopLink: "",
            twitterLink: "",
            watchLink: "",
            last5Games: [],
            seasonTotals: [seasonTotal],
            currentRoster: nil
        )
    }

    mutating func setCalculatedRating(_ rating: Int) {
        calculatedRating = rating
    }
    
    mutating func setHotStreakStatus(_ isHot: Bool) {
        isOnHotStreak = isHot
    }

    var description: String {
        "\(playerId)"
    }
}

struct NHLPlayerSkaterStatsLeaders: Codable, CustomStringConvertible {
    let goals: [NHLPlayerSkaterStats]?
    let assists: [NHLPlayerSkaterStats]?
    let points: [NHLPlayerSkaterStats]?

    var description: String {
        "\(goals?.first?.playerId ?? 0)"
    }
}

struct NHLPlayerGoalieStatsLeaders: Codable, CustomStringConvertible {
    let wins: [NHLPlayerSkaterStats]?
    let savePctg: [NHLPlayerSkaterStats]?
    let goalsAgainstAverage: [NHLPlayerSkaterStats]?

    var description: String {
        "\(wins?.first?.playerId ?? 0)"
    }
}
