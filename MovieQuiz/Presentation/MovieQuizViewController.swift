import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private let alertPresenter = AlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    func changeButtonClickability() {
        self.noButton.isEnabled.toggle()
        self.yesButton.isEnabled.toggle()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.addCorrectAnswer()
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func resetImageBorder() {
        self.imageView.layer.borderWidth = 0
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showQuizEndAlert(_ model: AlertModel) {
        alertPresenter.showAlert(on: self, with: model)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let networkErrorAlert = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                self.presenter.questionFactory?.loadData()
                self.presenter.questionFactory?.resetUsedIndex()
                self.presenter.questionFactory?.requestNextQuestion() {
                    self.presenter.changeButtonClickability()
                }
            }
        alertPresenter.showAlert(on: self, with: networkErrorAlert)
    }
}
