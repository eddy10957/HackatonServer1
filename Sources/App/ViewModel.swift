import Vapor
import Combine
import Foundation

final class PartyStoreViewModel {
    @Published private var parties: [Party] = []
    // Useless (?)
    //    @Published private var teams: [Team] = []
//    @Published private var players: [Player] = []
    
    
    @Published private var questions: [Question] = [
        Question(text: "What is a common collaboration tool used in remote teams?", answers: ["Slack", "Zoom", "Microsoft Teams", "Google Meet"], correctAnswer: "Slack"),
        Question(text: "What is an essential skill for effective remote communication?", answers: ["Active listening", "Body language", "Hand gestures", "Eye contact"], correctAnswer: "Active listening"),
        Question(text: "What is a benefit of remote work?", answers: ["Flexible schedule", "Long commutes", "Strict dress code", "Limited job opportunities"], correctAnswer: "Flexible schedule"),
        Question(text: "What is a challenge of remote work?", answers: ["Isolation", "Constant interruptions", "Commute time", "Limited work-life balance"], correctAnswer: "Isolation"),
        Question(text: "Which technology enables remote team collaboration on code?", answers: ["Git", "Subversion", "Mercurial", "CVS"], correctAnswer: "Git"),
        Question(text: "What is a key factor for successful remote project management?", answers: ["Clear communication", "Micromanagement", "In-person meetings", "Strict deadlines"], correctAnswer: "Clear communication"),
        Question(text: "Which time zone difference can often be challenging in global remote teams?", answers: ["12 hours", "3 hours", "6 hours", "9 hours"], correctAnswer: "12 hours"),
        Question(text: "What is a recommended practice to stay productive while working remotely?", answers: ["Create a dedicated workspace", "Work in bed", "Watch TV shows while working", "Ignore deadlines"], correctAnswer: "Create a dedicated workspace"),
        Question(text: "Which online tool can be used for remote project management?", answers: ["Trello", "Physical whiteboard", "Excel spreadsheet", "Notepad"], correctAnswer: "Trello"),
        Question(text: "What is a common challenge when managing remote teams?", answers: ["Building trust", "In-person meetings", "Physical workspace management", "Strict supervision"], correctAnswer: "Building trust")
    ]

//    @Published private var leaderboard: [LeaderboardEntry] = []
    
    
    // MARK: - Party Functions
    
    func createParty(_ party: Party) {
        parties.append(party)
    }
    
    func getParty(_ partyID: UUID) -> Party? {
        return parties.first(where: { $0.id == partyID })
    }
    
    func getPartyByCode(_ code: String) -> Party? {
        print("Get party by code : \(code)")
        return parties.first { $0.code == code }
    }
    
    func getAllParties() -> [Party]{
        return parties
    }
    
    func removeParty(_ partyID: UUID) {
        parties.removeAll(where: { $0.id == partyID })
    }
    func removePartyByCode(_ partyCode: String) {
        parties.removeAll(where: { $0.code == partyCode })
    }
    
    func startParty(partyCode: String){
        guard let partyIndex = parties.firstIndex(where: { $0.code == partyCode }) else {
            return
        }
        parties[partyIndex].isGameStarted = true
    }
    
    
    
    
    // MARK: - Team Functions
    
    
    func addTeamToParty(_ partyID: UUID, team: UUID, name: String) {
        guard let partyIndex = parties.firstIndex(where: { $0.id == partyID }) else {
            return
        }
        
        // Add the player to the party's team
        let team = Team(name: name)
        parties[partyIndex].teams.append(team)
        parties[partyIndex].teamLeaderBoard[team.name] = 0
    }
    
    func getTeam(partyCode: String ,teamID: UUID) -> Team? {
        let party = self.getPartyByCode(partyCode)
        return party?.teams.first(where: { $0.id == teamID })
    }
    func getTeamByName(partyCode: String ,teamName: String) -> Team? {
        let party = self.getPartyByCode(partyCode)
        return party?.teams.first(where: { $0.name == teamName })
    }
    
    func getAllTeams(partyCode: String) -> [Team] {
        let party = self.getPartyByCode(partyCode)
        return party?.teams ?? []
    }
    
    func removeTeam(partyCode: String, teamID: UUID) {
        var party = self.getPartyByCode(partyCode)
        party?.teams.removeAll(where: { $0.id == teamID })
    }
    
    // MARK: - Player Functions
   
    func addPlayerToParty(_ partyID: UUID, playerID: UUID, nickname: String) -> String {
        guard let partyIndex = parties.firstIndex(where: { $0.id == partyID }) else {
            return ""
        }
        
        // TODO: Aggiungi controllo nickname
        
        if parties[partyIndex].players.contains(where: {$0.name == nickname}) {
            return "Nickname Already Exists"
        } else {
            // Add the player to the party's team
            let player = Player(name: nickname)
            parties[partyIndex].players.append(player)
            parties[partyIndex].playerLeaderBoard[player.name] = 0
            return "Player Added to the Party"
        }
        
       
    }
    
    func addPlayerToTeam(_ partyID: UUID, playerID: UUID,teamID: UUID, nickname: String) {
        guard let partyIndex = parties.firstIndex(where: { $0.id == partyID }) else {
            return
        }
        guard let teamIndex = parties[partyIndex].teams.firstIndex(where: { $0.id == teamID }) else {
            return
        }
        
        // Add the player to the party's team
        let player = Player(name: nickname)
        
        parties[partyIndex].teams[teamIndex].players.append(player)
    }
    
    func getPlayer(playerID: UUID, partyID: UUID, teamName: String? = nil) -> Player? {
        guard let partyIndex = parties.firstIndex(where: { $0.id == partyID }) else {
            return nil
        }
        if let teamID = teamName {
            guard let teamIndex = parties[partyIndex].teams.firstIndex(where: { $0.name == teamID }) else {
                return nil
            }
            return parties[partyIndex].teams[teamIndex].players.first(where: { $0.id == playerID })
        }else{
            return parties[partyIndex].players.first(where: { $0.id == playerID })
        }
    }
    
    //MARK: - Leaderboard Functions -
    
    func getLeaderBoard(partyCode: String, mode: String)->[String:Int]?{
        guard let partyIndex = parties.firstIndex(where: { $0.code == partyCode }) else {
            return nil
        }
        var leaderboard : [String: Int] = [:]
        if mode == "team"{
            leaderboard = parties[partyIndex].teamLeaderBoard
        }else{
            leaderboard = parties[partyIndex].playerLeaderBoard
        }
        
        return leaderboard
    }
    
}
