//
//  File.swift
//  
//
//  Created by Edoardo Troianiello on 18/05/23.
//

import Foundation
import Vapor

import Vapor

struct Party: Content {
    var id: UUID?
    var code: String
    var isGameStarted: Bool
    var teams: [Team]
    var players: [Player]
    var teamLeaderBoard: [String : Int]
    var playerLeaderBoard: [String : Int]

    init(code: String, isGameStarted: Bool = false, teams: [Team] = [], players: [Player] = []) {
        self.id = UUID()
        self.code = code
        self.isGameStarted = isGameStarted
        self.teams = teams
        self.players = players
        self.teamLeaderBoard = [:]
        self.playerLeaderBoard = [:]
    }
}

struct Player: Content {
    var id: UUID?
    var name: String
    var score: Int
    var teamID: UUID?

    init(name: String, score: Int = 0, teamID: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.score = score
        self.teamID = teamID
    }
}

struct Team: Content {
    var id: UUID?
    var name: String
    var players: [Player]

    init(name: String, players: [Player] = []) {
        self.id = UUID()
        self.name = name
        self.players = players
    }
}

struct Question: Content {
    var id: UUID?
    var text: String
    var answers: [String]
    var correctAnswer: String

    init(text: String, answers: [String], correctAnswer: String) {
        self.id = UUID()
        self.text = text
        self.answers = answers
        self.correctAnswer = correctAnswer
    }
}

//struct Answer: Content {
//    var id: UUID?
//    var questionID: UUID
//    var playerID: UUID
//    var selectedAnswer: String
//
//    init(questionID: UUID, playerID: UUID, selectedAnswer: String) {
//        self.id = UUID()
//        self.questionID = questionID
//        self.playerID = playerID
//        self.selectedAnswer = selectedAnswer
//    }
//}
//
//struct LeaderboardEntry: Content {
//    var id: UUID?
//    var playerName: String
//    var score: Int
//
//    init(playerName: String, score: Int) {
//        self.id = UUID()
//        self.playerName = playerName
//        self.score = score
//    }
//}
