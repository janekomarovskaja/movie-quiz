import Foundation
import UIKit

class AlertPresenter: UIViewController {
    func showAlert(on viewController: MovieQuizViewController, with model: AlertModel) {
        let alert = UIAlertController (title: model.title, message: model.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            model.completion()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
