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

class CoreDataCollectionViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var fetchedResultsController: NSFetchedResultsController<Note>!
    var frcDelegate: CollectionViewFRCDelegate!
    var collectionViewDataSource: CollectionViewCoreDataSource<Note>!
    
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

        // Do any additional setup after loading the view.
        
        let configureCell: ConfigureCollectionViewCell = { (configuringCell, indexPath) in
            var cell: UICollectionViewCell? = nil
            if let actualCell = configuringCell {
                cell = actualCell
            } else {
                cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseIdentifier(), for: indexPath)
            }
            DataController.sharedController.viewContext.performAndWait {
                guard let noteCell = cell as? NoteCollectionViewCell else {
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
        
        navigationItem.title = "Collection View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteButtonPressed(sender:)))
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: NoteCollectionViewCell.reuseIdentifier())
        view.addSubview(collectionView)
        collectionView.sizeAndCenter(to: view)
        collectionViewDataSource = CollectionViewCoreDataSource(collectionView: collectionView, with: fetchedResultsController, with: configureCell)
        collectionView.dataSource = collectionViewDataSource
        
        frcDelegate = CollectionViewFRCDelegate(collectionView: collectionView, with: configureCell)
        
        view.setNeedsLayout()
        
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
