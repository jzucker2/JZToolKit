//
//  UserDataController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/21/17.
//
//

import UIKit
import CoreData

open class UserDataController: DataController {
    
    open override var managedObjectModel: NSManagedObjectModel? {
        var finalModel: NSManagedObjectModel? = nil
        
        let podBundle = Bundle(for: self.classForCoder)
        print("podBundle: \(podBundle.debugDescription)")
        guard let dataModelBundleURL = podBundle.url(forResource: "JZToolKit", withExtension: "bundle") else {
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
        print("toolKitModel: \(toolKitModel.debugDescription)")
        if let superModel = super.managedObjectModel {
            print("superModel: \(superModel.debugDescription)")
            finalModel = NSManagedObjectModel.init(byMerging: [superModel, toolKitModel])
        }
        print("finalModel: \(finalModel?.debugDescription)")
        return finalModel
    }

}
