//
//  DataController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/14/17.
//
//

import UIKit
import CoreData

@objc
public protocol DataControllerDelegate: NSObjectProtocol {
    @objc optional func controllerWithPersistentContainerType(_ controller: DataController) -> NSPersistentContainer.Type
    func controllerWithName(_ controller: DataController) -> String
    @objc optional func controllerWithManagedObjectModel(_ controller: DataController) -> NSManagedObjectModel
}

public class DataController: NSObject {
    
    public weak var delegate: DataControllerDelegate?
    
    public static let sharedController = DataController()
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        guard let name = self.delegate?.controllerWithName(self) else {
            fatalError("We need a name!")
        }
        let container: NSPersistentContainer
        let containerType: NSPersistentContainer.Type
        if let customType = self.delegate?.controllerWithPersistentContainerType?(self) {
            containerType = customType
        } else {
            containerType = NSPersistentContainer.self
        }
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        if let model = self.delegate?.controllerWithManagedObjectModel?(self) {
            container = containerType.init(name: name, managedObjectModel: model)
        } else {
            container = containerType.init(name: name)
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
        
    // MARK: - Core Data Saving support
    // if context is nil, then viewContext is used
    // for completion: context saved, true for saved, and false for no save, error if there is one
    public func save(context: NSManagedObjectContext? = nil, completion: ((NSManagedObjectContext, Bool, Error?) -> Void)? = nil) {
        var context = context
        if context == nil {
            context = viewContext
        }
        let existingContext = context!
        existingContext.perform {
            // we can forcibly unwrap because we know the context is not nil
            let existingContext = context!
            if existingContext.hasChanges {
                do {
                    try existingContext.save()
                    completion?(existingContext, true, nil)
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    completion?(existingContext, false, error)
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            } else {
                completion?(existingContext, false, nil)
            }
        }
    }

}
