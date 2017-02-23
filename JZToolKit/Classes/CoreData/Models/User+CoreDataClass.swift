//
//  User+CoreDataClass.swift
//  Pods
//
//  Created by Jordan Zucker on 2/21/17.
//
//

import Foundation
import CoreData



public protocol UniqueObject: NSObjectProtocol {
    typealias UpdateObject = (Object) throws -> ()
    associatedtype Object: NSManagedObject, NSFetchRequestResult
    var uniqueID: String? { get set }
    var creationDate: NSDate? { get set }
    static func fetchObject(in context: NSManagedObjectContext, with uniqueID: String?) -> Object?
    static func createOrUpdate(in context: NSManagedObjectContext, with uniqueID: String?, and update: UpdateObject?) -> Object
}

public extension UniqueObject where Object == NSManagedObject {
    static func fetchObject(in context: NSManagedObjectContext, with uniqueID: String?) -> Object? {
        var foundObject: Object? = nil
        context.performAndWait {
            do {
                guard let entityName = Object.entity().name else {
                    fatalError("We need a name for \(Object.debugDescription())")
                }
                let fetchRequest: NSFetchRequest<Object> = NSFetchRequest(entityName: entityName)
//                let predicate =
                let results = try fetchRequest.execute()
                assert(results.count <= 1)
                foundObject = results.first
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
        return foundObject
    }
    
    static func createOrUpdate(in context: NSManagedObjectContext, with uniqueID: String?, and update: UpdateObject?) -> Object {
        var foundObject: Object? = nil
        context.performAndWait {
            do {
                print("createOrUpdate")
                guard let entityName = Object.entity().name else {
                    fatalError("We need a name for \(Object.debugDescription())")
                }
                let fetchRequest: NSFetchRequest<Object> = NSFetchRequest(entityName: entityName)
                let results = try fetchRequest.execute()
                assert(results.count <= 1)
                foundObject = results.first
                if foundObject == nil {
                    print("create object")
                    foundObject = Object.init(context: context)
                }
                print("got object")
                try update?(foundObject!)
                print("after block")
            } catch {
                fatalError("We can't handle errors at this level, even: \(error.localizedDescription)")
            }
            print("after then execute block")
        }
        return foundObject!
    }
}

public protocol UniqueUser: UniqueObject {
    var name: String? { get set }
    var thumbnail: UIImage? { get set }
}

@objc(User)
public class User: NSManagedObject, UniqueUser {
    
    public typealias Object = User
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
        uniqueID = UUID().uuidString
    }
    
//    public class func user(in context: NSManagedObjectContext, with name: String?) -> User {
//        var createdUser: User? = nil
//        context.performAndWait {
//            createdUser = User(context: context)
//            
//        }
//    }

}
