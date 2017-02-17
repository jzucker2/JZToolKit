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
    associatedtype FetchRequestResult: NSFetchRequestResult
    weak var view: UIView? { get }
    
    var fetchedResultsController: NSFetchedResultsController<FetchRequestResult> { get }
    
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
}

extension CoreDataSource {
    
    public var numberOfSections: Int {
        print(#function)
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        print(#function)
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
}

open class TableViewCoreDataSource<ResultType> : NSObject, CoreDataSource, UITableViewDataSource where ResultType : NSFetchRequestResult {
    public typealias ViewType = UITableView
    
    public var view: UIView? {
        return tableView
    }
    
    public weak var tableView: UITableView?
    public let cellConfiguration: ConfigureTableViewCell
    public let fetchedResultsController: NSFetchedResultsController<ResultType>
    
    public required init(tableView: UITableView, with fetchedResultsController: NSFetchedResultsController<ResultType>, with cellConfiguration: @escaping ConfigureTableViewCell) {
        self.tableView = tableView
        self.cellConfiguration = cellConfiguration
        self.fetchedResultsController = fetchedResultsController
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellConfiguration(nil, indexPath)
    }
    
}

open class CollectionViewCoreDataSource<ResultType> : NSObject, CoreDataSource, UICollectionViewDataSource where ResultType : NSFetchRequestResult {
    
    public weak var collectionView: UICollectionView?
    public let cellConfiguration: ConfigureCollectionViewCell
    public let fetchedResultsController: NSFetchedResultsController<ResultType>
    
    public required init(collectionView: UICollectionView, with fetchedResultsController: NSFetchedResultsController<ResultType>, with cellConfiguration: @escaping ConfigureCollectionViewCell) {
        self.fetchedResultsController = fetchedResultsController
        self.cellConfiguration = cellConfiguration
        self.collectionView = collectionView
    }
    
    public typealias ViewType = UICollectionView
    
    public var view: UIView? {
        return collectionView
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellConfiguration(nil, indexPath)
    }
    
}
