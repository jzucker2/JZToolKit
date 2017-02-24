//
//  User+CoreDataClass.swift
//  Pods
//
//  Created by Jordan Zucker on 2/21/17.
//
//

import Foundation
import CoreData


@objc
public protocol UniqueObject: NSObjectProtocol {
    @objc var uniqueID: String? { get set }
}

@objc
public protocol NamedUniqueObject: UniqueObject {
    @objc var name: String? { get set }
}



@objc(User)
public class User: NSManagedObject, NamedUniqueObject {
    
    public typealias Object = User
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
        uniqueID = UUID().uuidString
    }

}
