//
//  Note+CoreDataClass.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/14/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import CoreData
import JZToolKit

@objc(Note)
public class Note: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
    }

}

extension Note: NamedUniqueObject { }
