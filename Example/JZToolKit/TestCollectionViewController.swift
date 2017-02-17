//
//  TestCollectionViewController.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import JZToolKit

class TestCollectionViewController: ToolKitViewController, UICollectionViewDataSource {
    
    struct DataSource {
        var items = [Note]()
        
        let numberOfSections = 1
        
        mutating func add(note: Note) -> IndexPath {
            items.insert(note, at: 0)
            return IndexPath(item: 0, section: 0)
        }
        
        subscript(item: Int) -> Note {
            get {
                return items[item]
            }
            set {
                items[item] = newValue
            }
        }
        
        subscript(indexPath: IndexPath) -> Note {
            get {
                return items[indexPath.item]
            }
            set {
                items[indexPath.item] = newValue
            }
        }
        
    }

    var collectionView: UICollectionView!
    
//    required init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    override func loadView() {
//        let bounds = UIScreen.main.bounds
//        let loadingView = UIView(frame: bounds)
//        loadingView.backgroundColor = .white
//        self.view = loadingView
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let bounds = UIScreen.main.bounds
//        self.view.frame = bounds
//    }
    
    var dataSource = DataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = "Collection View"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: NoteCollectionViewCell.reuseIdentifier())
        view.addSubview(collectionView)
        collectionView.sizeAndCenter(to: view)
        collectionView.dataSource = self
        
        
        DataController.sharedController.viewContext.perform {
            print("start adding slowly")
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            do {
                let results = try fetchRequest.execute()
                for (index, result) in results.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500) + .seconds(index), execute: {
                        print("add to data source for index: \(index)")
                        let insertedIndexPath = self.dataSource.add(note: result)
//                        print("schedule batch update for index: \(index)")
                        print("schedule update for index: \(index)")
                        self.collectionView.insertItems(at: [insertedIndexPath])
                        print("finish update for index: \(index)")
//                        self.collectionView.performBatchUpdates({
//                            print("==================================")
//                            print("start perform batch update for index: \(index)")
//                            self.collectionView.insertItems(at: [insertedIndexPath])
//                            print("end perform batch update for index: \(index)")
//                            print("==================================")
//                        }, completion: { (success) in
//                            print("********* batch updates completion is \(success) for index: \(index)")
//                        })
                    })
                }
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
        
        view.setNeedsLayout()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func addButtonPressed(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Custom
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        print("\(#function) for indexPath: \(indexPath)")
        DataController.sharedController.viewContext.perform {
            guard let noteCell = cell as? NoteCollectionViewCell else {
                fatalError()
            }
            let note = self.dataSource[indexPath]
            let update = NoteCellUpdate(name: note.name, creationDate: note.creationDate)
            noteCell.update(update)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        guard let sections = dataSource.numberOfSections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        return sections.count
        let numberOfSections = dataSource.numberOfSections
        print("\(#function) with numberOfSections: \(numberOfSections)")
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let sections = fetchedResultsController.sections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        let sectionInfo = sections[section]
//        return sectionInfo.numberOfObjects
        let numberOfItems = dataSource.items.count
        print("\(#function) section: \(section) with numberOfItems: \(numberOfItems)")
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseIdentifier(), for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }

}
