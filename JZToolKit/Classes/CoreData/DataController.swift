//
//  DataController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/14/17.
//
//

import UIKit
import CoreData

extension NSManagedObjectModel {
    
    func modelFromPod(containing object: NSObject, named: String) -> NSManagedObjectModel? {
        let aClass = object.classForCoder
        print("aClass: \(aClass.debugDescription())")
        return modelFromPod(for: aClass, named: named)
    }
    
    func modelFromPod(for aClass: AnyClass, named: String) -> NSManagedObjectModel? {
        var finalModel: NSManagedObjectModel? = nil
        
        let podBundle = Bundle(for: aClass)
        print("podBundle: \(podBundle.debugDescription)")
        guard let dataModelBundleURL = podBundle.url(forResource: named, withExtension: "bundle") else {
            fatalError("no pod bundle URL")
        }
        print("dataModelBundleURL: \(dataModelBundleURL.debugDescription)")
        guard let dataModelBundle = Bundle(url: dataModelBundleURL) else {
            fatalError("no pod bundle")
        }
        print("dataModelBundle: \(dataModelBundle.debugDescription)")
        guard let toolKitModel = NSManagedObjectModel.mergedModel(from: [dataModelBundle]) else {
            fatalError("no managed object model")
        }
        print("podModel: \(toolKitModel.debugDescription)")
        return finalModel
    }
    
}

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
    
    public func fetchObject<NSFetchRequestResult: UniqueObject where NSFetchRequestResult: NSManagedObject>(in context: NSManagedObjectContext? = nil, with uniqueID: String) -> NSFetchRequestResult? {
        var finalObject: NSFetchRequestResult? = nil
        finalObject = fetchResult(in: context, with: uniqueID, shouldCreateIfNil: false)
        return finalObject
    }
    
    public typealias UpdateResult = (Bool, NSFetchRequestResult) throws -> ()
    
    internal func fetchResult<NSFetchRequestResult: UniqueObject where NSFetchRequestResult: NSManagedObject>(in context: NSManagedObjectContext? = nil, with uniqueID: String, shouldCreateIfNil createObject: Bool, and update: UpdateResult? = nil) -> NSFetchRequestResult? {
//        print("\(#function) uniqueID: \(uniqueID) with createObject: \(createObject)")
        var context = context
        if context == nil {
            context = viewContext
        }
        var finalObject: NSFetchRequestResult? = nil
        context!.performAndWait {
            do {
//                print("\(#function) fetch uniqueID: \(uniqueID)")
                guard let entityName = NSFetchRequestResult.entity().name else {
                    fatalError("We need a name for \(NSFetchRequestResult.debugDescription())")
                }
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let predicate = NSPredicate(format: "%K == %@", #keyPath(UniqueObject.uniqueID), uniqueID)
                fetchRequest.predicate = predicate
//                print("\(#function) fetch uniqueID: \(uniqueID) fetchRequest: \(fetchRequest.debugDescription)")
                let results = try fetchRequest.execute()
                assert(results.count <= 1)
                finalObject = results.first
                var createdObject = false
                if createObject && (finalObject == nil) {
                    createdObject = true
//                    print("\(#function) fetch uniqueID: \(uniqueID) create object")
                    finalObject = NSFetchRequestResult.init(context: context!)
                    finalObject?.uniqueID = uniqueID // don't forget to set the uniqueID
                }
//                print("\(#function) fetch uniqueID: \(uniqueID) got object")
                try update?(createdObject, finalObject!)
//                print("\(#function) fetch uniqueID: \(uniqueID) after block")
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
//        print("\(#function) fetch uniqueID: \(uniqueID) return: \(finalObject.debugDescription)")
        return finalObject
    }
    
    public func createOrUpdate<NSFetchRequestResult: UniqueObject where NSFetchRequestResult: NSManagedObject>(in context: NSManagedObjectContext? = nil, with uniqueID: String? = nil, and update: UpdateResult? = nil) -> NSFetchRequestResult {
        var fetchingID = ""
        if let actualID = uniqueID {
            fetchingID = actualID
        } else {
            fetchingID = UUID().uuidString
        }
        var finalObject: NSFetchRequestResult? = nil
        finalObject = fetchResult(in: context, with: fetchingID, shouldCreateIfNil: true, and: update)
        return finalObject!
    }
    
    public func changeNameAlertController(in context: NSManagedObjectContext? = nil, for uniqueObject: NamedUniqueObject, shouldSave: Bool = true, with completion: ((UIAlertAction, String?) -> Swift.Void)? = nil) -> UIAlertController {
        var context = context
        if context == nil {
            context = viewContext
        }
        let alertController = UIAlertController(title: "Update name", message: "Choose a new name for your object", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Name ..."
            context!.perform {
                guard let actualName = uniqueObject.name else {
                    return
                }
                let workItem = DispatchWorkItem(qos: .userInteractive, flags: [], block: {
                    textField.text = actualName
                })
                DispatchQueue.main.async(execute: workItem)
            }
        }
        let textField = alertController.textFields![0] // we just created this above
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            // Probably need to do verification here
            let updatedName = textField.text! // crash for now, fix up later
            context!.perform {
                uniqueObject.name = updatedName
                if shouldSave {
                    self.save(context: context!)
                }
                completion?(action, updatedName)
            }
        }
        alertController.addAction(updateAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            context!.perform {
                completion?(action, uniqueObject.name)
            }
        }
        alertController.addAction(cancelAction)
        return alertController
    }

}
