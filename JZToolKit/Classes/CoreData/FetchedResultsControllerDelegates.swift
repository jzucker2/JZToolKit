//
//  FetchedResultsControllerDelegates.swift
//  Pods
//
//  Created by Jordan Zucker on 2/15/17.
//
//

import UIKit
import CoreData

public typealias ConfigureCollectionViewCell = (UICollectionViewCell?, IndexPath) -> (UICollectionViewCell)
public typealias ConfigureTableViewCell = (UITableViewCell?, IndexPath) -> (UITableViewCell)

public protocol DynamicDisplay: NSObjectProtocol { }

extension UICollectionView: DynamicDisplay { }
extension UITableView: DynamicDisplay { }

enum Change {
    // indexPath is first, then newIndexPath
    case object(IndexPath?, IndexPath?, NSFetchedResultsChangeType)
    case section(Int, NSFetchedResultsChangeType)
    
    func applyChange<T: FRCDelegate>(with delegate: T) {
        DispatchQueue.main.async {
            switch self {
            case let .object(indexPath, newIndexPath, changeType):
                switch changeType {
                case .insert:
//                    print("object insert")
                    delegate.insertItem(at: newIndexPath!)
                case .update:
//                    print("object update")
                    delegate.reloadItem(at: indexPath!)
                case .move:
//                    print("object move")
                    delegate.moveItem(at: indexPath!, to: newIndexPath!)
                case .delete:
//                    print("object delete")
                    delegate.deleteItem(at: indexPath!)
                }
            case let .section(sectionIndex, changeType):
                let indexSet = IndexSet(integer: sectionIndex)
                switch changeType {
                case .insert:
//                    print("section insert")
                    delegate.insertSections(indexSet)
                case .update:
//                    print("section update")
                    delegate.reloadSections(indexSet)
                case .delete:
//                    print("section delete")
                    delegate.deleteSections(indexSet)
                case .move:
                    print("section move")
//                    // Not something I'm worrying about right now.
                    print("Never implemented section move")
                    
                    break
                }
            }
        }
    }
    
}

public protocol FRCDelegate: NSObjectProtocol, NSFetchedResultsControllerDelegate {
    
    associatedtype ViewType
    weak var view: UIView? { get }
    
//    var completion: ((DynamicDisplay) -> ())? { get set }
    
    // MARK: - Sections
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func reloadSections(_ sections: IndexSet)
    
    // MARK: - Items
    func insertItem(at indexPath: IndexPath)
    func deleteItem(at indexPath: IndexPath)
    func reloadItem(at indexPath: IndexPath)
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    
}

public class TableViewFRCDelegate: NSObject, FRCDelegate {
    public typealias ViewType = UITableView

    public var view: UIView? {
        return tableView
    }
    
    public var completion: ((UITableView?) -> ())?
    
    internal weak var tableView: UITableView?
    private let cellConfiguration: ConfigureTableViewCell
    
    public required init(tableView: UITableView, with cellConfiguration: @escaping ConfigureTableViewCell) {
        self.tableView = tableView
        self.cellConfiguration = cellConfiguration
    }
    
    var animation: UITableViewRowAnimation {
        return .fade
    }
    
    public func insertSections(_ sections: IndexSet) {
//        print(#function)
        tableView?.insertSections(sections, with: animation)
    }
    
    public func deleteSections(_ sections: IndexSet) {
//        print(#function)
        tableView?.deleteSections(sections, with: animation)
    }
    
    public func reloadSections(_ sections: IndexSet) {
//        print(#function)
        tableView?.insertSections(sections, with: animation)
    }
    
    public func insertItem(at indexPath: IndexPath) {
//        print(#function)
        tableView?.insertRows(at: [indexPath], with: animation)
    }
    
    public func deleteItem(at indexPath: IndexPath) {
//        print(#function)
        tableView?.deleteRows(at: [indexPath], with: animation)
    }
    
    public func reloadItem(at indexPath: IndexPath) {
//        print(#function)
        guard let cell = tableView?.cellForRow(at: indexPath) else {
            return
        }
        _ = cellConfiguration(cell, indexPath)
    }
    
    public func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
//        print(#function)
        tableView?.moveRow(at: indexPath, to: newIndexPath)
    }
    
}

public class CollectionViewFRCDelegate: NSObject, FRCDelegate {
    
    internal weak var collectionView: UICollectionView?
    private let cellConfiguration: ConfigureCollectionViewCell
    
    public var completion: ((UICollectionView?) -> ())?
    
    public required init(collectionView: UICollectionView, with cellConfiguration: @escaping ConfigureCollectionViewCell) {
        self.cellConfiguration = cellConfiguration
        self.collectionView = collectionView
    }
    
    public typealias ViewType = UICollectionView
    
    public var view: UIView? {
        return collectionView
    }
    public func insertSections(_ sections: IndexSet) {
//        print(#function)
        collectionView?.insertSections(sections)
    }
    
    public func deleteSections(_ sections: IndexSet) {
//        print(#function)
        collectionView?.deleteSections(sections)
    }
    
    public func reloadSections(_ sections: IndexSet) {
//        print(#function)
        collectionView?.insertSections(sections)
    }
    
    public func insertItem(at indexPath: IndexPath) {
//        print(#function)
        collectionView?.insertItems(at: [indexPath])
    }
    
    public func deleteItem(at indexPath: IndexPath) {
//        print(#function)
        collectionView?.deleteItems(at: [indexPath])
    }
    
    public func reloadItem(at indexPath: IndexPath) {
//        print(#function)
        guard let cell = collectionView?.cellForItem(at: indexPath) else {
            return
        }
        _ = cellConfiguration(cell, indexPath)
    }
    
    public func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
//        print(#function)
        collectionView?.moveItem(at: indexPath, to: newIndexPath)
    }
    
}

extension TableViewFRCDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView?.beginUpdates()
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        print(#function)
        Change.section(sectionIndex, type).applyChange(with: self)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print(#function)
        Change.object(indexPath, newIndexPath, type).applyChange(with: self)
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView?.endUpdates()
            self.completion?(self.tableView)
        }
    }
    
}

extension CollectionViewFRCDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        print(#function)
        Change.section(sectionIndex, type).applyChange(with: self)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print(#function)
        Change.object(indexPath, newIndexPath, type).applyChange(with: self)
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.completion?(self.collectionView)
        }
    }
}
