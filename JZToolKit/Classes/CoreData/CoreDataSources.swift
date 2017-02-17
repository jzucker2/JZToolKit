//
//  CoreDataSources.swift
//  Pods
//
//  Created by Jordan Zucker on 2/16/17.
//
//

import UIKit
import CoreData

public protocol DynamicDisplayView: NSObjectProtocol { }

extension UICollectionViewCell: DynamicDisplayView { }
extension UITableViewCell: DynamicDisplayView { }

public protocol CoreDataSource {
    associatedtype ViewType
    weak var view: UIView? { get }
    
    //    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> { get }
    
    //    var numberOfSections: Int { get }
    //    func numberOfItems(in section: Int) -> Int
    //    func viewForItem(at indexPath: IndexPath) -> DynamicDisplayView
}

open class TableViewCoreDataSource<ResultType> : NSObject, CoreDataSource, UITableViewDataSource where ResultType : NSFetchRequestResult {
    public typealias ViewType = UITableView
    
    public var view: UIView? {
        return tableView
    }
    
    internal weak var tableView: UITableView?
    private let cellConfiguration: ConfigureTableViewCell
    private let fetchedResultsController: NSFetchedResultsController<ResultType>
    
    public init(tableView: UITableView, with fetchedResultsController: NSFetchedResultsController<ResultType>, with cellConfiguration: @escaping ConfigureTableViewCell) {
        self.tableView = tableView
        self.cellConfiguration = cellConfiguration
        self.fetchedResultsController = fetchedResultsController
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellConfiguration(nil, indexPath)
    }
    
}

open class CollectionViewCoreDataSource<ResultType> : NSObject, CoreDataSource, UICollectionViewDataSource where ResultType : NSFetchRequestResult {
    
    internal weak var collectionView: UICollectionView?
    private let cellConfiguration: ConfigureCollectionViewCell
    private let fetchedResultsController: NSFetchedResultsController<ResultType>
    
    public init(collectionView: UICollectionView, with fetchedResultsController: NSFetchedResultsController<ResultType>, with cellConfiguration: @escaping ConfigureCollectionViewCell) {
        self.fetchedResultsController = fetchedResultsController
        self.cellConfiguration = cellConfiguration
        self.collectionView = collectionView
    }
    
    public typealias ViewType = UICollectionView
    
    public var view: UIView? {
        return collectionView
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellConfiguration(nil, indexPath)
    }
    
    
}
