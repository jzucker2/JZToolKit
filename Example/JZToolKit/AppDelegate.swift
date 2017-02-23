//
//  AppDelegate.swift
//  JZToolKit
//
//  Created by jzucker2 on 02/14/2017.
//  Copyright (c) 2017 jzucker2. All rights reserved.
//

import UIKit
import JZToolKit

fileprivate let InitialLaunchKey = "InitialLaunchKey"

class TestDataController: DataController {
    
    static let current = TestDataController()
    
    override var persistentContainerName: String? {
        return "Example"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !UserDefaults.standard.bool(forKey: InitialLaunchKey) {
            TestDataController.current.performBackgroundTask { (context) in
                for index in 0..<10 {
                    let name = "Note \(index)"
                    let text = "This is a sample of note \(index)"
                    _ = Note.createNote(in: context, with: name, text: text)
                }
                TestDataController.current.save(context: context)
                UserDefaults.standard.set(true, forKey: InitialLaunchKey)
            }
        }
        
        
        let bounds = UIScreen.main.bounds
        let window = UIWindow(frame: bounds)
        self.window = window
        
        let coreDataTableViewController = CoreDataTableViewController()
        let tableNavController = UINavigationController(rootViewController: coreDataTableViewController)
        tableNavController.tabBarItem.title = "TableView"
        
        let coreDataCollectionViewController = CoreDataCollectionViewController()
        let collectionNavController = UINavigationController(rootViewController: coreDataCollectionViewController)
        collectionNavController.tabBarItem.title = "CollectionView"
        
        let testCollectionViewController = TestCollectionViewController()
        let testCollectionViewNavController = UINavigationController(rootViewController: testCollectionViewController)
        testCollectionViewNavController.tabBarItem.title = "Test CV"
        
        let errorViewController = ErrorViewController()
        let errorNavController = UINavigationController(rootViewController: errorViewController)
        errorNavController.tabBarItem.title = "Errors"
        
        let toolkitNavController = ToolKitViewController.embedInNavigationController()
        toolkitNavController.tabBarItem.title = "TKVC"
        toolkitNavController.topViewController?.view.backgroundColor = .red
        
        let subclassToolKitNavController = SubclassToolKitViewController.embedInNavigationController()
        subclassToolKitNavController.tabBarItem.title = "Subclass"
        
        let userMainViewController = UserMainViewController.embedInNavigationController()
        userMainViewController.tabBarItem.title = "User"
        
        let fetchNoteVC = FetchNoteViewController.embedInNavigationController()
        fetchNoteVC.tabBarItem.title = "Fetch"
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [tableNavController, collectionNavController, testCollectionViewNavController, errorNavController, toolkitNavController, subclassToolKitNavController, userMainViewController, fetchNoteVC]
        
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        TestDataController.current.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

