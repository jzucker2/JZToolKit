//
//  CoreDataCollectionViewController.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/15/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import JZToolKit

class CoreDataCollectionViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var collectionView: UICollectionView!
    var fetchedResultsController: NSFetchedResultsController<Note>!
    var frcDelegate: CollectionViewFRCDelegate!
    
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
    
    var configureCell: ConfigureCollectionViewCell!
//    let configureCell: ConfigureCollectionViewCell = { (cell, indexPath) in
//        DataController.sharedController.viewContext.perform {
//            guard let noteCell = cell as? NoteCollectionViewCell else {
//                fatalError()
//            }
//            let note = self.fetchedResultsController.object(at: indexPath)
//            let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
//            noteCell.update(update)
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureCell = { (cell, indexPath) in
            DataController.sharedController.viewContext.perform {
                guard let noteCell = cell as? NoteCollectionViewCell else {
                    fatalError()
                }
                let note = self.fetchedResultsController.object(at: indexPath)
                let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
                noteCell.update(update)
            }
        }
        navigationItem.title = "Collection View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteButtonPressed(sender:)))
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: NoteCollectionViewCell.reuseIdentifier())
        view.addSubview(collectionView)
        collectionView.sizeAndCenter(to: view)
        collectionView.dataSource = self
        
//        let configureCell: ConfigureCollectionViewCell = { (cell, indexPath) in
//            DataController.sharedController.viewContext.perform {
//                guard let noteCell = cell as? NoteCollectionViewCell else {
//                    fatalError()
//                }
//                let note = self.fetchedResultsController.object(at: indexPath)
//                let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
//                noteCell.update(update)
//            }
//        }
        frcDelegate = CollectionViewFRCDelegate(collectionView: collectionView, with: configureCell)
        
        view.setNeedsLayout()
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Note.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [creationDateSortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
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
    
    // MARK: - Custom
    
//    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
//        DataController.sharedController.viewContext.perform {
//            guard let noteCell = cell as? NoteCollectionViewCell else {
//                fatalError()
//            }
//            let note = self.fetchedResultsController.object(at: indexPath)
//            let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
//            noteCell.update(update)
//        }
//    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseIdentifier(), for: indexPath)
//        configureCell(cell: cell, indexPath: indexPath)
        configureCell(cell, indexPath)
        return cell
    }

}
