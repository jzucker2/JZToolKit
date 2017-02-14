//
//  ValueTransformers.swift
//  Pods
//
//  Created by Jordan Zucker on 2/14/17.
//
//

import UIKit

@objc(ImageToDataTransformer)
public class ImageToDataTransformer: ValueTransformer {
    
    public class override func allowsReverseTransformation() -> Bool {
        return true
    }
    
    public class override func transformedValueClass() -> Swift.AnyClass {
        return NSData.self
    }
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let image = value as? UIImage else {
            fatalError("can only handle UIImage, not: \(value.debugDescription)")
        }
        let data = UIImageJPEGRepresentation(image, 1.0)
        return data
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("can only handle Data, not: \(value.debugDescription)")
        }
        let image = UIImage(data: data)
        return image
    }
    
}
