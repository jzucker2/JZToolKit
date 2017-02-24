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
    var createAndFetchButton: UIButton!

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
        
        createAndFetchButton = UIButton(type: .system)
        createAndFetchButton.setTitle("Create and fetch", for: .normal)
        createAndFetchButton.addTarget(self, action: #selector(createAndFetchButtonPressed(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(createAndFetchButton)
        
        
        
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
        
        let fetchedNote: Note = TestDataController.current.createOrUpdate(in: TestDataController.current.viewContext, with: currentNoteIdentifier) { (foundNote) in
            guard let updatedNote = foundNote as? Note else {
                fatalError("how did we not get a note from: \(foundNote.debugDescription)")
            }
            print("originalNote: \(updatedNote.debugDescription)")
            guard let oldText = updatedNote.text else {
                fatalError("We expected text!")
            }
            updatedNote.text = "\(oldText) and I added more!"
        }
//
        print("fetchedNote: \(fetchedNote.debugDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let fetchedAgain: Note? = TestDataController.current.fetchObject(in: TestDataController.current.viewContext, with: currentNoteIdentifier)
            print("fetchedAgain: \(fetchedAgain!.debugDescription)")
        }
        
    }
    
    func createAndFetchButtonPressed(sender: UIButton) {
        let newNoteIdentifier = UUID().uuidString
        let fetchedNote: Note = TestDataController.current.createOrUpdate(in: TestDataController.current.viewContext, with: newNoteIdentifier, and: { (foundNote) in
            guard let updatedNote = foundNote as? Note else {
                fatalError("how did we not get a note from: \(foundNote.debugDescription)")
            }
            print("originalNote: \(updatedNote.debugDescription)")
            updatedNote.name = "New note!!"
            updatedNote.text = "I was created from scratch"
        })
        
        print("fetchedNote: \(fetchedNote.debugDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let fetchedAgain: Note? = TestDataController.current.fetchObject(in: TestDataController.current.viewContext, with: newNoteIdentifier)
            print("fetchedAgain: \(fetchedAgain!.debugDescription)")
        }
        
        print("fetchedNote: \(fetchedNote.debugDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            let fetchedAgain: Note = TestDataController.current.createOrUpdate(with: newNoteIdentifier, and: { (foundNote) in
                guard let updatedNote = foundNote as? Note else {
                    fatalError("how did we not get a note from: \(foundNote.debugDescription)")
                }
                print("originalNote: \(updatedNote.debugDescription)")
                guard let oldText = updatedNote.text else {
                    fatalError("We expected text!")
                }
                updatedNote.text = "\(oldText) and added to later"
            })
            print("fetchedAgain: \(fetchedAgain.debugDescription)")
        }
    }
    
    func createAndFetchButtonPressedAgain(sender: UIButton) {
        let newNoteIdentifier = UUID().uuidString
        let fetchedNote: Note = TestDataController.current.createOrUpdate(with: newNoteIdentifier, and: { (foundNote) in
            guard let updatedNote = foundNote as? Note else {
                fatalError("how did we not get a note from: \(foundNote.debugDescription)")
            }
            print("originalNote: \(updatedNote.debugDescription)")
            updatedNote.name = "New note!!"
            updatedNote.text = "I was created from scratch"
        })
        
        print("fetchedNote: \(fetchedNote.debugDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let fetchedAgain: Note? = TestDataController.current.fetchObject(with: newNoteIdentifier)
            print("fetchedAgain: \(fetchedAgain!.debugDescription)")
        }
        
        print("fetchedNote: \(fetchedNote.debugDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            let fetchedAgain: Note = TestDataController.current.createOrUpdate(in: TestDataController.current.viewContext, with: newNoteIdentifier, and: { (foundNote) in
                guard let updatedNote = foundNote as? Note else {
                    fatalError("how did we not get a note from: \(foundNote.debugDescription)")
                }
                print("originalNote: \(updatedNote.debugDescription)")
                guard let oldText = updatedNote.text else {
                    fatalError("We expected text!")
                }
                updatedNote.text = "\(oldText) and added to later"
            })
            print("fetchedAgain: \(fetchedAgain.debugDescription)")
        }
    }

}
