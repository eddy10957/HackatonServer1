import Vapor
import Foundation


//TODO: - Check If party is not started in order to add ppl or teams to it
//      - Check if party is Group or individual and accept only the correct way to add ppl to party
//      - Change model of question in order to have all the different minigames under that struct
//      - When party is created we need to generate all the quiz
//      - Point logic, we need to calculate points
//      - Leaderboard, I don't know how to do it, propably we will need a Model refactoring
//      - Subsmission of answers
//      - Get questions
//      - Dato che sono stronzo e ho fatto dei controlli sui nomi, non dobbiamo permettere nicknames e nomi di team uguali. Controllo che nono sono già presenti altri player e team con quel nome.
//      - Chek party code non esiste prima di assegnarlo.
//      - Change Party model by adding a boolean to change mode between individual or team ( POTREBBE NON SERVIRE PENSIAMOCI. )




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
    app.post("createParty",":partyName") { req -> Party in
        print("create party req")
        guard let partyName = req.parameters.get("partyName", as: String.self) else{
            throw Abort(.badRequest)
        }
        let partyCode = generatePartyCode()
        // Create the party and add it to the store
        let party = Party(code: partyCode,name: partyName)
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
        if partyStoreViewModel.addPlayerToParty(party.id!, playerID: playerID, nickname: nickname) == "Player Added to the Party" {
            return .ok
        } else if partyStoreViewModel.addPlayerToParty(party.id!, playerID: playerID, nickname: nickname)  == "Nickname Already Exists" {
            throw Abort(.imATeapot)
        }
        
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
    
    
    
    
    
    
    
    
    // Submit an answer
    //    app.post("parties", ":partyID", "answers") { req -> HTTPStatus in
    //        let partyID = try req.parameters.require("partyID", as: UUID.self)
    //        let answer = try req.content.decode(Answer.self)
    //        partyStoreViewModel.submitAnswer(answer)
    //        return .ok
    //    }
    
    
    //MARK: - Leaderboard Routes -
    //     Get leaderboard (individual)
    app.get("leaderboard", ":partyCode", "individual") { req -> [String:Int] in
        let partyCode = try req.parameters.require("partyCode", as: String.self)
        // Fetch and return the individual leaderboard for the party with the provided partyID
        let leaderboard = partyStoreViewModel.getLeaderBoard(partyCode: partyCode, mode: "individual")
        return leaderboard!
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
    
}
