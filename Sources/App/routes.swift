import Vapor
import Foundation

let partyStoreViewModel = PartyStoreViewModel()



func generatePartyCode() -> String {
    let characters = "0123456789"
    let codeLength = 4
    let code = String((0..<codeLength).map { _ in characters.randomElement()! })
    
    return code
}

func routes(_ app: Application) throws {
    
    //MARK: - Party Routes
    
    
    // Create a new party
    app.post("createParty") { req -> Party in
        print("create party req")
        let partyCode = generatePartyCode()
        // Create the party and add it to the store
        let party = Party(code: partyCode)
        partyStoreViewModel.createParty(party)
        
        return party
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
        partyStoreViewModel.addPlayerToParty(party.id!, playerID: playerID, nickname: nickname)
        
        return .ok
    }
    
    // Get all parties
    app.get("parties") { req -> [Party] in
        return partyStoreViewModel.getAllParties()
    }
    
    // Get party details
    app.get("parties", ":partyID") { req -> Party in
        let partyCode = try req.parameters.require("partyID", as: String.self)
        // Fetch the party details from the ViewModel using the partyID
        let party = partyStoreViewModel.getPartyByCode(partyCode)!
        return party
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
        
        
        let team = Team(name: teamName)
        partyStoreViewModel.addTeamToParty(party.id!, team: team.id!, name: team.name)
        return team
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
        partyStoreViewModel.addPlayerToTeam(party.id!, playerID: playerID, teamID: team.id!, nickname: playerName)
        
        // Add the player to the team with the provided teamID
        return .ok
    }
    
    
    
    
    
    
    
    
    
    // Start the game
    app.post("start", ":partyID") { req -> HTTPStatus in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        // Start the game for the party with the provided partyID
        return .ok
    }
    
  
    
    
    // Submit an answer
    //    app.post("parties", ":partyID", "answers") { req -> HTTPStatus in
    //        let partyID = try req.parameters.require("partyID", as: UUID.self)
    //        let answer = try req.content.decode(Answer.self)
    //        partyStoreViewModel.submitAnswer(answer)
    //        return .ok
    //    }
    
    // Get leaderboard (individual)
    //    app.get("parties", ":partyID", "leaderboard", "individual") { req -> [LeaderboardEntry] in
    //        let partyID = try req.parameters.require("partyID", as: UUID.self)
    //        // Fetch and return the individual leaderboard for the party with the provided partyID
    //        let leaderboard = partyStoreViewModel.getIndividualLeaderboard(partyID)
    //        return leaderboard
    //    }
    //
    //    // Get leaderboard (team)
    //    app.get("parties", ":partyID", "leaderboard", "team") { req -> [LeaderboardEntry] in
    //        let partyID = try req.parameters.require("partyID", as: UUID.self)
    //        // Fetch and return the team leaderboard for the party with the provided partyID
    //        let leaderboard = partyStoreViewModel.getTeamLeaderboard(partyID)
    //        return leaderboard
    //    }
    
    
}
