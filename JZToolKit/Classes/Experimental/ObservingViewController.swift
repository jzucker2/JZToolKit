//
//  ObservingViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/19/17.
//
//

import UIKit

class ObservingViewController: ToolKitViewController, Observer {

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
                //                _ = self?.perform(action)
                _ = self?.perform(action)
            })
            DispatchQueue.main.async(execute: mainQueueUpdate)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //    open override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        updateKVO(with: .add)
    //    }
    //
    //    open override func viewDidDisappear(_ animated: Bool) {
    //        super.viewDidDisappear(animated)
    //        updateKVO(with: .remove)
    //    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        observedObject = nil
    }

}
