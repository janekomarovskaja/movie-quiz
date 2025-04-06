import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion(completion: (() -> Void)?)
    func resetUsedIndex()
    func loadData()
}
