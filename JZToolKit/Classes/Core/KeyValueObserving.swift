//
//  KeyValueObserving.swift
//  Pods
//
//  Created by Jordan Zucker on 2/17/17.
//
//

import Foundation

public struct KVOActions: OptionSet {

    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let add = KVOActions(rawValue: 1 << 0)
    public static let remove = KVOActions(rawValue: 1 << 1)
    public static let removeOldValue = KVOActions(rawValue: 1 << 2)
    
    public static let propertyObserverActions: KVOActions = [.add, .removeOldValue]
}


public protocol Observer: NSObjectProtocol {
    var kvoContext: Int { get set }
    associatedtype Object: NSObject
    var observedObject: Object? { get set }
    static var observerResponses: [String:Selector]? { get }
}

open class ObservingObject: NSObject, Observer {

    public var kvoContext: Int = 0
    open class var observerResponses: [String:Selector]? {
        return nil
    }
    
    public func updateKVO(with actions: KVOActions, oldValue: NSObject? = nil) {
        guard let observingKeyPaths = type(of: self).observerResponses else {
            print("No observer responses exist")
            return
        }
        for (keyPath, _) in observingKeyPaths {
            if actions.contains(.removeOldValue) {
                oldValue?.removeObserver(self, forKeyPath: keyPath, context: &kvoContext)
            }
            if actions.contains(.remove) {
                observedObject?.removeObserver(self, forKeyPath: keyPath, context: &kvoContext)
            }
            if actions.contains(.add) {
                observedObject?.addObserver(self, forKeyPath: keyPath, options: [.new, .old, .initial], context: &kvoContext)
            }
        }
    }
    
    open var observedObject: NSObject? {
        didSet {
            print("hey there: \(#function)")
            updateKVO(with: .propertyObserverActions, oldValue: oldValue)
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
                _ = self?.perform(action)
            })
            DispatchQueue.main.async(execute: mainQueueUpdate)
        } else {
            
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
