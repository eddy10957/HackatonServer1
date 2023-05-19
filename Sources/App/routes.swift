import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    // Create a new party
    app.post("parties") { req -> Party in
        let party = try req.content.decode(Party.self)
        // Save the party and return it
        return party
    }

    // Join an existing party
    app.post("parties", ":partyID", "join") { req -> HTTPStatus in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        let player = try req.content.decode(Player.self)
        // Join the party with the provided partyID
        // Add the player to the party
        return .ok
    }

    // Create a new team
    app.post("teams") { req -> Team in
        let team = try req.content.decode(Team.self)
        // Save the team and return it
        return team
    }

    // Add player to a team
    app.post("teams", ":teamID", "players") { req -> HTTPStatus in
        let teamID = try req.parameters.require("teamID", as: UUID.self)
        let player = try req.content.decode(Player.self)
        // Add the player to the team with the provided teamID
        return .ok
    }

    // Start the game
    app.post("parties", ":partyID", "start") { req -> HTTPStatus in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        // Start the game for the party with the provided partyID
        return .ok
    }

    // Get party details
    app.get("parties", ":partyID") { req -> Party in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        // Fetch the party details from the database using the partyID
        // Return the party
        return party
    }

    // Submit an answer
    app.post("parties", ":partyID", "answers") { req -> HTTPStatus in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        let answer = try req.content.decode(Answer.self)
        // Submit the answer for the party with the provided partyID
        return .ok
    }

    // Get leaderboard (individual)
    app.get("parties", ":partyID", "leaderboard", "individual") { req -> [LeaderboardEntry] in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        // Fetch and return the individual leaderboard for the party with the provided partyID
        return leaderboardEntries
    }

    // Get leaderboard (team)
    app.get("parties", ":partyID", "leaderboard", "team") { req -> [LeaderboardEntry] in
        let partyID = try req.parameters.require("partyID", as: UUID.self)
        // Fetch and return the team leaderboard for the party with the provided partyID
        return leaderboardEntries
    }

}
