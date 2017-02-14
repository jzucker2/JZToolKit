//
//  ViewController.swift
//  JZToolKit
//
//  Created by jzucker2 on 02/14/2017.
//  Copyright (c) 2017 jzucker2. All rights reserved.
//

import UIKit
import CoreData
import JZToolKit

class ViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Note>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier())
        tableView.forceAutoLayout()
        view.addSubview(tableView)
        tableView.sizeAndCenter(to: view)
        tableView.dataSource = self
        view.setNeedsLayout()
        
        navigationItem.title = "Main View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteButtonPressed(sender:)))
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Note.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [creationDateSortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func addNoteButtonPressed(sender: UIBarButtonItem) {
        DataController.sharedController.performBackgroundTask { (context) in
            let newName = "Added note"
            let newText = "Another note with same text"
            _ = Note.createNote(in: context, with: newName, text: newText)
            DataController.sharedController.save(context: context)
        }
    }
    
    // MARK: - Custom
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        DataController.sharedController.viewContext.perform {
            guard let noteCell = cell as? NoteTableViewCell else {
                fatalError()
            }
            let note = self.fetchedResultsController.object(at: indexPath)
            let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
            noteCell.update(update)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier(), for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let insertedIndexPath = newIndexPath!
            tableView.insertRows(at: [insertedIndexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            guard let cell = tableView.cellForRow(at: indexPath!) else {
                fatalError()
            }
            configureCell(cell: cell, indexPath: indexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

