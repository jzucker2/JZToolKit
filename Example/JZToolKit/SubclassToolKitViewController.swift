//
//  SubclassToolKitViewController.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import JZToolKit

class SubclassToolKitViewController: ToolKitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .blue
        observedObject = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var observedObject: NSObject? {
        didSet {
            print("whatever")
        }
    }

}
