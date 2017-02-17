//
//  StackViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 2/17/17.
//
//

import UIKit

@objc protocol StackViewControllerDelegate: NSObjectProtocol {
    @objc optional func stackViewStatusBarHeight(_ stackView: StackViewController) -> CGFloat
}

open class StackViewController: ToolKitViewController {
    
    open func setUp(customStackView: UIStackView) {
        customStackView.axis = .vertical
        customStackView.alignment = .fill
        customStackView.distribution = .fill
    }
    
    open var stackView: UIStackView!
    weak var delegate: StackViewControllerDelegate?
    
    open override func loadView() {
        super.loadView()
        stackView = UIStackView(frame: .zero)
        setUp(customStackView: stackView)
        view.addSubview(stackView)
        view.bringSubview(toFront: stackView)
    }
    
    open var adjustsStackViewForTabBar = true {
        didSet {
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(#function)
        let bounds = UIScreen.main.bounds
        var topPadding: CGFloat = 0.0
        if let statusBarHeight = delegate?.stackViewStatusBarHeight?(self) {
            topPadding += statusBarHeight
        }
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            topPadding += navBarHeight
        }
        var bottomPadding: CGFloat = 0.0
        if adjustsStackViewForTabBar {
            if let tabBarHeight = tabBarController?.tabBar.frame.height {
                bottomPadding += tabBarHeight
            }
        }
        let stackViewFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y + topPadding, width: bounds.size.width, height: bounds.size.height - topPadding - bottomPadding)
        stackView.frame = stackViewFrame
        view.frame = bounds
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
