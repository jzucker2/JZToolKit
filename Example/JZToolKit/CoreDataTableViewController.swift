//
//  CoreDataTableViewController.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/15/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import JZToolKit

class CoreDataTableViewController: UIViewController {

    var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Note>!
    var frcDelegate: TableViewFRCDelegate!
    var tableViewDataSource: TableViewCoreDataSource<Note>!
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let bounds = UIScreen.main.bounds
        let loadingView = UIView(frame: bounds)
        loadingView.backgroundColor = .white
        self.view = loadingView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = UIScreen.main.bounds
        self.view.frame = bounds
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let configureCell: ConfigureTableViewCell = { (configuringCell, indexPath) in
            var cell: UITableViewCell? = nil
            if let actualCell = configuringCell {
                cell = actualCell
            } else {
                cell = self.tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier(), for: indexPath)
            }
            DataController.sharedController.viewContext.performAndWait {
                guard let noteCell = cell as? NoteTableViewCell else {
                    fatalError()
                }
                let note = self.fetchedResultsController.object(at: indexPath)
                let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
                noteCell.update(update)
            }
            return cell!
        }
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Note.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [creationDateSortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier())
        tableView.forceAutoLayout()
        view.addSubview(tableView)
        tableView.sizeAndCenter(to: view)
        tableViewDataSource = TableViewCoreDataSource(tableView: tableView, with: fetchedResultsController, with: configureCell)
        tableView.dataSource = tableViewDataSource
        view.setNeedsLayout()
                
        navigationItem.title = "Table View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteButtonPressed(sender:)))
        
        
        
        frcDelegate = TableViewFRCDelegate(tableView: tableView, with: configureCell)
        
        fetchedResultsController.delegate = frcDelegate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        view.setNeedsLayout()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func addNoteButtonPressed(sender: UIBarButtonItem) {
        DataController.sharedController.saveNewNotesInBackground()
    }

}
