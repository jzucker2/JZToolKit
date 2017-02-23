//
//  FetchNoteViewController.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/23/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import JZToolKit

class FetchNoteViewController: StackViewController {
    
    var noteIdentifier: String?
    var fetchButton: UIButton!
    var instructionsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var firstNote: Note? = nil
        TestDataController.current.viewContext.perform {
            let latestNoteFetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            do {
                print("perform do")
                let results = try latestNoteFetchRequest.execute()
                firstNote = results.first
                print("finish do")
            } catch {
                fatalError(error.localizedDescription)
            }
            print("now do after do/catch stuff")
            self.noteIdentifier = firstNote?.uniqueID
        }
        
        instructionsLabel = UILabel(frame: .zero)
        instructionsLabel.textAlignment = .center
        instructionsLabel.text = "Stop trying to"
        stackView.addArrangedSubview(instructionsLabel)
        
        fetchButton = UIButton(type: .system)
        fetchButton.setTitle("Make fetch happen", for: .normal)
        fetchButton.addTarget(self, action: #selector(fetchButtonPressed(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(fetchButton)
        
        view.setNeedsLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func fetchButtonPressed(sender: UIButton) {
        guard let currentNoteIdentifier = noteIdentifier else {
            return
        }
        print("currentNoteIdentifier: \(currentNoteIdentifier)")
        guard let fetchedNote: Note = TestDataController.current.fetchObject(in: TestDataController.current.viewContext, with: currentNoteIdentifier) else {
            print("found no note")
            return
        }
        print("fetchedNote: \(fetchedNote.debugDescription)")
    }

}
