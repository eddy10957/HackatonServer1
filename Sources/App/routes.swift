import Vapor
import Foundation


//TODO:
//      - Check if party is Group or individual and accept only the correct way to add ppl to party
//      - Change model of question in order to have all the different minigames under that struct

//      - Change Party model by adding a boolean to change mode between individual or team ( POTREBBE NON SERVIRE PENSIAMOCI. )




let partyStoreViewModel = PartyStoreViewModel()



//func generatePartyCode() -> String {
//    let characters = "0123456789"
//    let codeLength = 4
//    let code = String((0..<codeLength).map { _ in characters.randomElement()! })
//
//    return code
//}

func routes(_ app: Application) throws {
    
    //MARK: - Party Routes
    
    
    // Create a new party
    app.post("createParty",":partyName") { req -> Party in
        print("create party req")
        guard let partyName = req.parameters.get("partyName", as: String.self) else{
            throw Abort(.badRequest)
        }
        let partyCode = partyStoreViewModel.generatePartyCode()
        // Create the party and add it to the store
        let party = Party(code: partyCode,name: partyName)
        if partyStoreViewModel.createParty(party) {
            return party
        } else {
            throw Abort(.imATeapot)
        }
    }
    
    // Join a party
    app.post("joinParty",":partyCode") { req -> HTTPStatus in
        print("Join Party Req")
        guard let partyCode = req.parameters.get("partyCode", as: String.self),
              let nickname = req.query[String.self, at: "nickname"] else {
            throw Abort(.badRequest)
        }
        
        // Find the party by code in the store
        print(partyCode)
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        
        // Join the party and add the player to the team
        let playerID = UUID()
        if partyStoreViewModel.addPlayerToParty(party.id!, playerID: playerID, nickname: nickname) {
            return .ok
        } else {
            throw Abort(.imATeapot)
        }
    }
    
    // Get all parties
    app.get("parties") { req -> [Party] in
        return partyStoreViewModel.getAllParties()
    }
    
    // Get party details
    app.get("parties", ":partyID") { req -> Party in
        let partyCode = try req.parameters.require("partyID", as: String.self)
        // Fetch the party details from the ViewModel using the partyID
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            throw Abort(.badRequest)
        }
        return party
    }
    
    // Start the game
    app.post("start", ":partyID") { req -> HTTPStatus in
        let partyCode = try req.parameters.require("partyID", as: String.self)
        // Start the game for the party with the provided partyID
        partyStoreViewModel.startParty(partyCode: partyCode)
        return .ok
    }
    
    //MARK: - Teams Routes -
    
    // Create a new team
    app.post("createTeam",":partyCode",":teamName") { req -> Team in
        print("inside create a team")
        guard let partyCode = req.parameters.get("partyCode", as: String.self),let teamName = req.parameters.get("teamName", as: String.self) else {
            throw Abort(.badRequest)
        }
        
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        
        
        
        if party.isGameStarted {
            throw Abort(.imATeapot)
        } else {
            let team = Team(name: teamName)
            if partyStoreViewModel.addTeamToParty(party.id!, team: team.id!, name: team.name) {
                return team
            } else {
                throw Abort(.imATeapot)
            }
        }
    }
    
    app.post("createTeams", ":partyCode"){ req -> [Team] in
        guard let partyCode = try? req.parameters.require("partyCode", as: String.self),
              let teams = try? req.content.decode([Team].self) else {
            throw Abort(.badRequest)
        }
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        partyStoreViewModel.addTeamsToParty(partyCode: partyCode, teams: teams)
        return teams
    }
    
    app.get("getTeams",":partyCode") { req -> [Team] in
        guard let partyCode = req.parameters.get("partyCode", as: String.self) else {
            throw Abort(.badRequest)
        }
        return partyStoreViewModel.getAllTeams(partyCode: partyCode)
    }
    
    
    
    // Add player to a team
    app.post("joinTeam",":partyCode") { req -> HTTPStatus in
        
        guard let partyCode = req.parameters.get("partyCode", as: String.self),
              let teamName = req.query[String.self, at: "teamName"] ,  let playerName = req.query[String.self, at: "nickName"]  else {
            throw Abort(.badRequest)
        }
        
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        
        guard let team = partyStoreViewModel.getTeamByName(partyCode: partyCode, teamName: teamName) else {
            print("team not found")
            throw Abort(.notFound)
        }
        
        let playerID = UUID()
        if partyStoreViewModel.addPlayerToTeam(party.id!, playerID: playerID, teamID: team.id!, nickname: playerName) {
            // Add the player to the team with the provided teamID
            return .ok
        } else {
            throw Abort(.imATeapot)
        }
        
       
    }
    
    
    app.post("teamPoint",":partyCode") { req -> HTTPStatus in
        
        guard let partyCode = req.parameters.get("partyCode", as: String.self),
              let player = req.query[String.self, at: "nickName"] ,  let points = req.query[Int.self, at: "points"], let teamName = req.query[String.self, at: "teamName"]  else {
            throw Abort(.badRequest)
        }
        
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        partyStoreViewModel.updatePoint(playerName: player, partyCode: partyCode, points: points, teamName: teamName)
        return .ok
    }


    
    
    
    
    //MARK: - Player Routes-
    
    //TODO: Restrutturare. Fa schifo scritta così
    app.get("player",":playerID") { req -> Player in
        guard let playerID = req.parameters.get("playerID", as: UUID.self),
              let partyID = req.query[UUID.self, at: "partyID"] ,  let teamName = req.query[String.self, at: "teamName"]  else {
            throw Abort(.badRequest)
        }
        
        guard let player = partyStoreViewModel.getPlayer(playerID: playerID, partyID: partyID, teamName: teamName == "nil" ? nil : teamName ) else {
            throw Abort(.notFound)
        }
        return player
        
    }
    
    app.post("playerPoint",":partyCode") { req -> HTTPStatus in
        
        guard let partyCode = req.parameters.get("partyCode", as: String.self),
              let player = req.query[String.self, at: "nickName"] ,  let points = req.query[Int.self, at: "points"]  else {
            throw Abort(.badRequest)
        }
        
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        partyStoreViewModel.updatePoint(playerName: player, partyCode: partyCode, points: points)
        return .ok
    }
    
    
    //MARK: - Leaderboard Routes -
    //     Get leaderboard (individual)
    app.get("leaderboard", ":partyCode", "individual") { req -> [String:Int] in
        let partyCode = try req.parameters.require("partyCode", as: String.self)
        // Fetch and return the individual leaderboard for the party with the provided partyID
        guard let leaderboard = partyStoreViewModel.getLeaderBoard(partyCode: partyCode, mode: "individual") else {
           throw Abort(.badRequest)
        }
        return leaderboard
    }
    
    // Get leaderboard (team)
    app.get("leaderboard", ":partyCode", "team") { req -> [String:Int] in
        let partyCode = try req.parameters.require("partyCode", as: String.self)
        // Fetch and return the team leaderboard for the party with the provided partyID
        let leaderboard = partyStoreViewModel.getLeaderBoard(partyCode: partyCode, mode: "team")
        return leaderboard!
    }
    
    
    //MARK: - Questions Routes -
    
    app.post("postQuestions", ":partyCode"){ req -> [Question] in
        guard let partyCode = try? req.parameters.require("partyCode", as: String.self),
              let questions = try? req.content.decode([Question].self) else {
            throw Abort(.badRequest)
        }
        guard let party = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        partyStoreViewModel.addQuestionToParty(partyCode: partyCode, questions: questions)
        return questions
    }
    
    app.get("question",":partyCode",":index"){ req -> Question in
        let partyCode = try req.parameters.require("partyCode", as: String.self)
        let index = try req.parameters.require("index", as: Int.self)
        guard let _ = partyStoreViewModel.getPartyByCode(partyCode) else {
            print("partycode not found")
            throw Abort(.notFound)
        }
        guard let question = partyStoreViewModel.questionNumber(partyCode: partyCode, index: index) else {
            throw Abort(.notFound)
        }
        return question
    }
    
    app.get("questionBank"){ req -> [Question] in
        return partyStoreViewModel.getQuestionBank()
    }
    
    
    
    
}
