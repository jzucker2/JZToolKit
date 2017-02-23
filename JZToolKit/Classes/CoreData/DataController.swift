//
//  DataController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/14/17.
//
//

import UIKit
import CoreData



open class DataController: NSObject {
    
    open static let sharedController = DataController()
    
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
    
    open var persistentContainerName: String? {
        return nil
    }
    
    open var persistentContainerType: NSPersistentContainer.Type {
        return NSPersistentContainer.self
    }
    
    open var managedObjectModel: NSManagedObjectModel? {
        return nil
    }
    
    internal lazy var persistentContainer: NSPersistentContainer = {
        
        guard let name = self.persistentContainerName else {
            fatalError("We need a name!")
        }
        let container: NSPersistentContainer

        let containerType = self.persistentContainerType
        
        if let model = self.managedObjectModel {
            container = containerType.init(name: name, managedObjectModel: model)
        } else {
            container = containerType.init(name: name)
        }
        
        print("container: \(container.persistentStoreDescriptions)")
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
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
        container.viewContext.automaticallyMergesChangesFromParent = true // we want this on
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
    
    // MARK: - Objects
    
    public func fetchObject<NSFetchRequestResult: UniqueObject where NSFetchRequestResult: NSManagedObject>(in context: NSManagedObjectContext, with uniqueID: String) -> NSFetchRequestResult? {
        var foundObject: NSFetchRequestResult? = nil
        context.performAndWait {
            do {
//                guard let entityName = NSFetchRequestResult.en.entity().name else {
//                    fatalError("We need a name for \(FetchedObject.debugDescription())")
//                }
                
//                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                //                let predicate =
//                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = foundObject.fetchRequest()
//                let entityName = foundObject.entityName
                guard let entityName = NSFetchRequestResult.entity().name else {
                    fatalError("We need a name for \(NSFetchRequestResult.debugDescription())")
                }
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
//                let predicate = NSPredicate(format: "%K == %@", #keyPath(UniqueObject.uniqueID), uniqueID)
                let predicate = NSPredicate(format: "%K == %@", "identifier", uniqueID)
                fetchRequest.predicate = predicate
                let results = try fetchRequest.execute()
                assert(results.count <= 1)
                foundObject = results.first
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
        return foundObject
    }
    
//    typealias UpdateObject = (UniqueObject) throws -> ()
    public typealias UpdateResult = (NSFetchRequestResult) throws -> ()
    
    public func createOrUpdate<NSFetchRequestResult: UniqueObject where NSFetchRequestResult: NSManagedObject>(in context: NSManagedObjectContext, with uniqueID: String, and update: UpdateResult?) -> NSFetchRequestResult {
        var finalObject: NSFetchRequestResult? = nil
        context.performAndWait {
            do {
                print("createOrUpdate")
                //                guard let entityName = NSFetchRequestResult.en.entity().name else {
                //                    fatalError("We need a name for \(FetchedObject.debugDescription())")
                //                }
                
                //                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                //                let predicate =
                //                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = foundObject.fetchRequest()
                //                let entityName = foundObject.entityName
                guard let entityName = NSFetchRequestResult.entity().name else {
                    fatalError("We need a name for \(NSFetchRequestResult.debugDescription())")
                }
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let predicate = NSPredicate(format: "%K == %@", #keyPath(UniqueObject.uniqueID), uniqueID)
                fetchRequest.predicate = predicate
                let results = try fetchRequest.execute()
                assert(results.count <= 1)
                finalObject = results.first
                if finalObject == nil {
                    print("create object")
                    finalObject = NSFetchRequestResult.init(context: context)
                }
                print("got object")
                try update?(finalObject!)
                print("after block")
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
        return finalObject!
    }
    
//    func createOrUpdate(in context: NSManagedObjectContext, with uniqueID: String?, and update: UpdateObject?) -> Object {
//        var foundObject: Object? = nil
//        context.performAndWait {
//            do {
//                print("createOrUpdate")
//                guard let entityName = Object.entity().name else {
//                    fatalError("We need a name for \(Object.debugDescription())")
//                }
//                let fetchRequest: NSFetchRequest<Object> = NSFetchRequest(entityName: entityName)
//                let results = try fetchRequest.execute()
//                assert(results.count <= 1)
//                foundObject = results.first
//                if foundObject == nil {
//                    print("create object")
//                    foundObject = Object.init(context: context)
//                }
//                print("got object")
//                try update?(foundObject!)
//                print("after block")
//            } catch {
//                fatalError("We can't handle errors at this level, even: \(error.localizedDescription)")
//            }
//            print("after then execute block")
//        }
//        return foundObject!
//    }

}
