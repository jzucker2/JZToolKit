//
//  ErrorGenerator.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import JZToolKit

enum ExamplePromptError: PromptError {
    
    case show
    case ignore
    
    var prompt: String {
        return "This is an example prompt error"
    }
}

enum ExampleAlertControllerError: AlertControllerError {
    
    case show
    case ignore
    
    var alertTitle: String {
        return "Alert Error!"
    }
    
    var alertMessage: String {
        return "This is an example of an alert controller error"
    }
}

struct ErrorGenerator {
    static func generatePromptError() throws {
        throw ExamplePromptError.show
    }
    
    static func generateAlertControllerError() throws {
        throw ExampleAlertControllerError.show
    }
}
