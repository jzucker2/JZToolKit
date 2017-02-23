//
//  User+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 2/21/17.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var uniqueID: String?
    @NSManaged public var name: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var thumbnail: UIImage?

}
