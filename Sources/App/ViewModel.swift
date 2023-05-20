import Vapor
import Combine
import Foundation

final class PartyStoreViewModel {
    @Published private var parties: [Party] = []
    @Published private var teams: [Team] = []
    @Published private var players: [Player] = []
    @Published private var questions: [Question] = []
    @Published private var answers: [Answer] = []
    @Published private var leaderboard: [LeaderboardEntry] = []
    
    // Other properties and methods as needed
    
    init() {
        // Initialize your data here if needed
    }
    
    
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
    
    

    
    // MARK: - Team Functions
    
    func createTeam(_ team: Team) {
        teams.append(team)
    }
    
    func getTeam(_ teamID: UUID) -> Team? {
        return teams.first(where: { $0.id == teamID })
    }
    
    func removeTeam(_ teamID: UUID) {
        teams.removeAll(where: { $0.id == teamID })
    }
    
    // MARK: - Player Functions
    
    func addPlayer(_ player: Player) {
        players.append(player)
    }
    func addPlayerToParty(_ partyID: UUID, playerID: UUID, nickname: String) {
            guard let partyIndex = parties.firstIndex(where: { $0.id == partyID }) else {
                return
            }
            
            // Add the player to the party's team
            let player = Player(name: nickname)
            parties[partyIndex].players.append(player)
        }
    
    func getPlayer(_ playerID: UUID) -> Player? {
        return players.first(where: { $0.id == playerID })
    }
    
    // MARK: - Answer Functions
    
    func submitAnswer(_ answer: Answer) {
        answers.append(answer)
    }
    
    func getPlayerAnswers(_ playerID: UUID) -> [Answer] {
        return answers.filter({ $0.playerID == playerID })
    }
    
    
//    func getPartyAnswers(_ partyID: UUID) -> [Answer] {
//        return answers.filter({ $0.partyID == partyID })
//    }
//    
//    // MARK: - Leaderboard Functions
//    
//    func getIndividualLeaderboard(_ partyID: UUID) -> [LeaderboardEntry] {
//        let partyAnswers = getPartyAnswers(partyID)
//        var leaderboard: [LeaderboardEntry] = []
//        
//        // Logic to calculate individual scores and create leaderboard entries
//        
//        return leaderboard
//    }
//    
//    func getTeamLeaderboard(_ partyID: UUID) -> [LeaderboardEntry] {
//        let partyAnswers = getPartyAnswers(partyID)
//        var leaderboard: [LeaderboardEntry] = []
//        
//        // Logic to calculate team scores and create leaderboard entries
//        
//        return leaderboard
//    }
    
    
}
