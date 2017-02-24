//
//  Note+CoreDataProperties.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/14/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note");
    }

    @NSManaged public var name: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var thumbnail: UIImage?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var text: String?

}
