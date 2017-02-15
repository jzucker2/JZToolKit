//
//  DataControllerExtensions.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/15/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import JZToolKit

extension DataController {
    
    func saveNewNotesInBackground() {
        DataController.sharedController.performBackgroundTask { (context) in
            let newName = "Added note"
            let newText = "Another note with same text"
            _ = Note.createNote(in: context, with: newName, text: newText)
            DataController.sharedController.save(context: context)
        }
    }
    
}
