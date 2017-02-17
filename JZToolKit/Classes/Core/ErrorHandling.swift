//
//  ErrorHandling.swift
//  Pods
//
//  Created by Jordan Zucker on 2/17/17.
//
//

import UIKit

public protocol AlertControllerError: Error {
    /// Title for the UIAlertController
    var alertTitle: String { get }
    var alertMessage: String { get }
}

public protocol PromptError: Error {
    var prompt: String { get }
}

public extension UINavigationItem {
    
    func setPrompt(with error: PromptError, for duration: Double = 3.0) {
        setPrompt(with: error.prompt, for: duration)
    }
}

public extension UIAlertController {
    
    static func alertController(error: AlertControllerError, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let title = error.alertTitle
        let message = error.alertMessage
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        return alertController
    }
    
}

public extension UIViewController {
    
    func show(promptError: PromptError, for duration: Double = 3.0) {
        DispatchQueue.main.async {
            self.navigationItem.setPrompt(with: promptError, for: duration)
        }
    }
    
    func show(alertControllerError: AlertControllerError, handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController.alertController(error: alertControllerError, handler: handler)
            self.present(alertController, animated: true)
        }
    }
    
}
