import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private let alertPresenter = AlertPresenter()
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    var usedQuestionsIndex = [Int]()
    private var movies: [MostPopularMovie] = []
    
    func requestNextQuestion(completion: (() -> Void)?) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            var index = (0..<self.movies.count).randomElement() ?? 0
            
            guard self.movies.count > 0 else { return }
            
            while usedQuestionsIndex.contains(index) {
                index = (0..<self.movies.count).randomElement()!
            }
            
            usedQuestionsIndex.append(index)
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            enum сomparison: String, CaseIterable {
                case equal = "равен"
                case greater = "больше чем"
                case less = "меньше чем"
            }
            
            let ratingValue = (8..<10).randomElement() ?? 0
            
            let randomComparison = сomparison.allCases.randomElement() ?? .equal
            
            let text = "Рейтинг этого фильма \(randomComparison.rawValue) \(ratingValue)?"
            
            var correctAnswer: Bool
            switch randomComparison {
            case .equal:
                correctAnswer = rating == Float(ratingValue)
            case .greater:
                correctAnswer = rating > Float(ratingValue)
            case .less:
                correctAnswer = rating < Float(ratingValue)
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
            completion?()
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func resetUsedIndex() {
        usedQuestionsIndex.removeAll()
    }
}
