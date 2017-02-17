//
//  ToolKitViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/17/17.
//
//

import UIKit

// This is a programmatic view controller to consolidate repeated programmatic set up
open class ToolKitViewController: UIViewController, Observer {
    
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
        
    open class func embedInNavigationController(navigationControllerType: UINavigationController.Type = UINavigationController.self, tabBarItem: UITabBarItem? = nil) -> UINavigationController {
        let rootViewController = self.init()
        let navController = navigationControllerType.init(rootViewController: rootViewController)
        if let actualTabBarItem = tabBarItem {
            navController.tabBarItem = actualTabBarItem
        }
        return navController
    }
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    // Figure out something about this, maybe implement myself
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This creates a view programmatically for you, assumes you are not using storyboards
    open override func loadView() {
        let bounds = UIScreen.main.bounds
        let loadingView = UIView(frame: bounds)
        loadingView.backgroundColor = .white
        self.view = loadingView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observedObject = fetchObservedObject()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observedObject = nil
    }
    
    deinit {
        observedObject = nil
    }

}
