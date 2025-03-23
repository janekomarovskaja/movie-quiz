import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case bestGame
        case gamesCount
        case totalCorrectAnswers
        case totalQuestions
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGame.rawValue + ".correct")
            let total = storage.integer(forKey: Keys.bestGame.rawValue + ".total")
            let date = storage.object(forKey: Keys.bestGame.rawValue + ".date") as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGame.rawValue + ".correct")
            storage.set(newValue.total, forKey: Keys.bestGame.rawValue + ".total")
            storage.set(newValue.date, forKey: Keys.bestGame.rawValue + ".date")
        }
    }
    
    var totalAccuracy: Double {
        get {
            let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
            
            return totalQuestions > 0 ? Double(totalCorrectAnswers) / Double(totalQuestions) * 100 : 0.0
        }
    }
    
    
    func store(correct count: Int, total amount: Int) {
        let newResult = GameResult(correct: count, total: amount, date: Date())
        
        if newResult.isBetterThan(bestGame) {
            bestGame = newResult
        }
        
        gamesCount += 1
        
        let currentCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(currentCorrectAnswers + count, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let currentTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(currentTotalQuestions + amount, forKey: Keys.totalQuestions.rawValue)
    }
}
