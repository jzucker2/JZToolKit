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
//    typealias UpdateObject = (UniqueObject) throws -> ()
    associatedtype Object: NSManagedObject, NSFetchRequestResult
    var uniqueID: String? { get set }
//    static var uniqueIDPropertyName: String { get }
//    func uniqueIDPredicate() -> NSPredicate
//    func uniqueIDFetchRequest() -> NSFetchRequest<Object>
//    var creationDate: NSDate? { get set }
//    static func fetchObject(in context: NSManagedObjectContext, with uniqueID: String?) -> Object?
//    static func createOrUpdate(in context: NSManagedObjectContext, with uniqueID: String?, and update: UpdateObject?) -> Object
//    static func fetchObject(in context: NSManagedObjectContext, with uniqueID: String?) -> NSManagedObject?
//    static func createOrUpdate(in context: NSManagedObjectContext, with uniqueID: String?, and update: UpdateObject?) -> NSManagedObject
}

//public extension UniqueObject where Object: NSManagedObject {
//    static func fetchObject(in context: NSManagedObjectContext, with uniqueID: String?) -> Object? {
//        guard let actualUniqueID = uniqueID else {
//            return nil
//        }
//        var foundObject: Object? = nil
//        context.performAndWait {
//            do {
//                guard let entityName = Object.entity().name else {
//                    fatalError("We need a name for \(Object.debugDescription())")
//                }
//                let fetchRequest: NSFetchRequest<Object> = NSFetchRequest(entityName: entityName)
////                let predicate =
//                let predicate = NSPredicate(format: "%K == %@", #keyPath(User.userID), actualUniqueID)
//                fetchRequest.predicate = predicate
//                let results = try fetchRequest.execute()
//                assert(results.count <= 1)
//                foundObject = results.first
//            } catch {
//                fatalError(error.localizedDescription)
//            }
//            
//        }
//        return foundObject
//    }
//    
//    static func createOrUpdate(in context: NSManagedObjectContext, with uniqueID: String?, and update: UpdateObject?) -> Object {
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
//}

//public protocol UniqueUser: UniqueObject {
//    var name: String? { get set }
//    var thumbnail: UIImage? { get set }
//}

@objc(User)
public class User: NSManagedObject, UniqueObject {
    
    public typealias Object = User
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
        userID = UUID().uuidString
    }
    
    public static var uniqueIDPropertyName: String {
        return #keyPath(User.userID)
    }
    
    public var uniqueID: String? {
        set {
            self.userID = newValue
        }
        get {
            return self.userID
        }
    }
    
    
//    public class func user(in context: NSManagedObjectContext, with name: String?) -> User {
//        var createdUser: User? = nil
//        context.performAndWait {
//            createdUser = User(context: context)
//            
//        }
//    }

}
