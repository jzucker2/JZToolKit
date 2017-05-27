//
//  CoreDataExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 5/27/17.
//
//

import CoreData


public protocol Managed: class, NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

public protocol DefaultManaged: Managed {}

extension DefaultManaged {
    public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
}


extension Managed {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
    public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
    
    public static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
    
    public static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
        let request = sortedFetchRequest
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request
    }
    
    public static func predicate(format: String, _ args: CVarArg...) -> NSPredicate {
        let p = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return predicate(p)
    }
    
    public static func predicate(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }
    
}


extension Managed where Self: NSManagedObject {
    
    public static var entity: NSEntityDescription { return entity()  }
    
    public static var entityName: String { return entity.name!  }
    
    public static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        return object
    }
    
    
    public static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return object
    }
    
    public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
    public static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return try! context.count(for: request)
    }
    
    public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
    
}


extension Managed where Self: NSManagedObject {
    public static func fetchSingleObject(in context: NSManagedObjectContext, cacheKey: String, configure: (NSFetchRequest<Self>) -> ()) -> Self? {
        if let cached = context.object(forSingleObjectCacheKey: cacheKey) as? Self { return cached
        }
        let result = fetchSingleObject(in: context, configure: configure)
        context.set(result, forSingleObjectCacheKey: cacheKey)
        return result
    }
    
    fileprivate static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> ()) -> Self? {
        let result = fetch(in: context) { request in
            configure(request)
            request.fetchLimit = 2
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }
}

public typealias SaveOrRollbackCompletion = (Bool, Error?) -> ()

extension NSManagedObjectContext {
    
    private var store: NSPersistentStore {
        guard let psc = persistentStoreCoordinator else { fatalError("PSC missing") }
        guard let store = psc.persistentStores.first else { fatalError("No Store") }
        return store
    }
    
    public var metaData: [String: AnyObject] {
        get {
            guard let psc = persistentStoreCoordinator else { fatalError("must have PSC") }
            return psc.metadata(for: store) as [String : AnyObject]
        }
        set {
            performChanges(for: {
                guard let psc = self.persistentStoreCoordinator else { fatalError("PSC missing") }
                psc.setMetadata(newValue, for: self.store)
            })
        }
    }
    
    public func setMetaData(object: AnyObject?, forKey key: String) {
        var md = metaData
        md[key] = object
        metaData = md
    }
    
    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }
    
    public func saveOrRollback(with completion: SaveOrRollbackCompletion? = nil) -> Bool {
        do {
            try save()
            completion?(true, nil)
            return true
        } catch {
            rollback()
            print("Error: \(error.localizedDescription)")
            completion?(false, error)
            return false
        }
    }
    
    public func performSaveOrRollback(with completion: SaveOrRollbackCompletion? = nil) {
        perform {
            _ = self.saveOrRollback(with: completion)
        }
    }
    
    public func performChanges(for block: @escaping () -> (), with completion: SaveOrRollbackCompletion? = nil) {
        perform {
            block()
            _ = self.saveOrRollback(with: completion)
        }
    }
    
}


private let SingleObjectCacheKey = "SingleObjectCache"
private typealias SingleObjectCache = [String:NSManagedObject]

extension NSManagedObjectContext {
    public func set(_ object: NSManagedObject?, forSingleObjectCacheKey key: String) {
        var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
        cache[key] = object
        userInfo[SingleObjectCacheKey] = cache
    }
    
    public func object(forSingleObjectCacheKey key: String) -> NSManagedObject? {
        guard let cache = userInfo[SingleObjectCacheKey] as? [String:NSManagedObject] else { return nil }
        return cache[key]
    }
}

extension Collection where Iterator.Element: NSManagedObject {
    public func fetchFaults() {
        guard !self.isEmpty else { return }
        guard let context = self.first?.managedObjectContext else { fatalError("Managed object must have context") }
        let faults = self.filter { $0.isFault }
        guard let object = faults.first else { return }
        let request = NSFetchRequest<Iterator.Element>()
        request.entity = object.entity
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "self in %@", faults)
        let _ = try! context.fetch(request)
    }
}
