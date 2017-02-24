//
//  DataControllerExtensions.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/15/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import JZToolKit

extension TestDataController {
    
    func saveNewNotesInBackground() {
        TestDataController.current.performBackgroundTask { (context) in
            let newName = "Added note"
            let newText = "Another note with same text"
//            _ = Note.createNote(in: context, with: newName, text: newText)
            _ = TestDataController.current.createNote(in: context, with: newName, and: newText)
            TestDataController.current.save(context: context)
        }
    }
    
}
