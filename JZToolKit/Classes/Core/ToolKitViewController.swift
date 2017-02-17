//
//  ToolKitViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/17/17.
//
//

import UIKit

// This is a programmatic view controller to consolidate repeated programmatic set up
open class ToolKitViewController: UIViewController {
        
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
    
//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print(#function)
//        let bounds = UIScreen.main.bounds
//        self.view.frame = bounds
//    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
