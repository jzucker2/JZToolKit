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
//        uniqueID = UUID().uuidString
    }
    
    static func createNote(in context: NSManagedObjectContext, with name: String, text: String?) -> Note {
        let note = Note(context: context)
        note.name = name
        note.text = text
        note.uniqueID = UUID().uuidString
        return note
    }

}

extension Note: UniqueObject { }

//extension Note: UniqueObject {
//    
//    public var uniqueID: String? {
//        set {
//            self.identifier = newValue
//        }
//        get {
//            return self.identifier
//        }
//    }
//
//}
