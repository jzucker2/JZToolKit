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

class URLToStringTransformer: ValueTransformer {
    
    class override func allowsReverseTransformation() -> Bool {
        return true
    }
    
    class override func transformedValueClass() -> Swift.AnyClass {
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let url = value as? NSURL else {
            fatalError("can only handle NSURL, not: \(value.debugDescription)")
        }
        return url.absoluteString
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let urlString = value as? String else {
            fatalError("can only handle String, not: \(value.debugDescription)")
        }
        return NSURL(string: urlString)
    }
    
}
