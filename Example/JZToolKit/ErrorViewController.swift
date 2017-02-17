//
//  ErrorViewController.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import JZToolKit

class ErrorViewController: StackViewController {
    
    var alertControllerErrorButton: UIButton!
    var navControllerErrorButton: UIButton!
    
    override func setUp(customStackView: UIStackView) {
        customStackView.axis = .vertical
        customStackView.alignment = .fill
        customStackView.distribution = .fillEqually
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Errors"
        alertControllerErrorButton = UIButton(type: .system)
        alertControllerErrorButton.addTarget(self, action: #selector(alertControllerErrorButtonPressed(sender:)), for: .touchUpInside)
        alertControllerErrorButton.setTitle("Trigger Alert Controller Error", for: .normal)
        stackView.addArrangedSubview(alertControllerErrorButton)
        
        navControllerErrorButton = UIButton(type: .system)
        navControllerErrorButton.addTarget(self, action: #selector(navControllerErrorButtonPressed(sender:)), for: .touchUpInside)
        navControllerErrorButton.setTitle("Trigger Nav Controller Prompt Error", for: .normal)
        stackView.addArrangedSubview(navControllerErrorButton)
        
        view.setNeedsLayout()        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertControllerErrorButtonPressed(sender: UIButton) {
        print(#function)
        do {
            try ErrorGenerator.generateAlertControllerError()
        } catch let alertError as ExampleAlertControllerError {
            if alertError == .show {
                show(alertControllerError: alertError)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func navControllerErrorButtonPressed(sender: UIButton) {
        print(#function)
        do {
            try ErrorGenerator.generatePromptError()
        } catch let promptError as ExamplePromptError {
            if promptError == .show {
                show(promptError: promptError)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}
