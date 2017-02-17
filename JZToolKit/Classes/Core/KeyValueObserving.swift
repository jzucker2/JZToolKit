//
//  KeyValueObserving.swift
//  Pods
//
//  Created by Jordan Zucker on 2/17/17.
//
//

import Foundation

public protocol Observer: NSObjectProtocol {
    var kvoContext: Int { get set }
    associatedtype Object: NSObject
    var observedObject: Object? { get set }
    static var observerResponses: [String:Selector]? { get }
    func fetchObservedObject() -> Object?
}

extension Observer {
    public func fetchObservedObject() -> NSObject? {
        return nil
    }
}

open class ObservingObject: NSObject, Observer {

    public var kvoContext: Int = 0
    open class var observerResponses: [String:Selector]? {
        return nil
    }
    
    open var observedObject: NSObject? {
        didSet {
            print("hey there: \(#function)")
            guard let observingKeyPaths = type(of: self).observerResponses else {
                print("No observer responses exist")
                return
            }
            for (keyPath, _) in observingKeyPaths {
                oldValue?.removeObserver(self, forKeyPath: keyPath, context: &kvoContext)
                observedObject?.addObserver(self, forKeyPath: keyPath, options: [.new, .old, .initial], context: &kvoContext)
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("self: \(self.debugDescription) \(#function) context: \(context)")
        if context == &kvoContext {
            guard let observingKeyPaths = type(of: self).observerResponses else {
                print("No observing Key Paths exist")
                return
            }
            guard let actualKeyPath = keyPath, let action = observingKeyPaths[actualKeyPath] else {
                fatalError("we should have had an action for this keypath since we are observing it")
            }
            let mainQueueUpdate = DispatchWorkItem(qos: .userInitiated, flags: [.enforceQoS], block: { [weak self] in
                //                _ = self?.perform(action)
                _ = self?.perform(action)
            })
            DispatchQueue.main.async(execute: mainQueueUpdate)
        } else {
            
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
