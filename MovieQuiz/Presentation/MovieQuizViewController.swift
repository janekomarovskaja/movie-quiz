import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private let alertPresenter = AlertPresenter()
    let statisticService = StatisticServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.changeButtonClickability()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let bestGame = statisticService.bestGame
            let dateFormatted = bestGame.date.dateTimeString
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateFormatted))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let alertView = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory.resetUsedIndex()
                    self?.questionFactory.requestNextQuestion()
                }
            )
            alertPresenter.showAlert(on: self, with: alertView)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        changeButtonClickability()
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        changeButtonClickability()
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    private func changeButtonClickability() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }
}
