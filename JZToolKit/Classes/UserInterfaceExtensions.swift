//
//  UserInterfaceExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 2/14/17.
//
//

import Foundation
import UIKit

// http://stackoverflow.com/questions/26542035/create-uiimage-with-solid-color-in-swift
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIView {
    
    static func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
}

extension UIView {
    func roundCorners() {
        // There are more efficient ways to do this,
        // I should be drawing a UIBezierPath
        // TODO: Clean this up
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
    }
}

extension UIView {
    
    var hasConstraints: Bool {
        let hasHorizontalConstraints = !self.constraintsAffectingLayout(for: .horizontal).isEmpty
        let hasVerticalConstraints = !self.constraintsAffectingLayout(for: .vertical).isEmpty
        return hasHorizontalConstraints || hasVerticalConstraints
    }
    
    func forceAutoLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func center(in view: UIView) {
        forceAutoLayout()
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func size(to view: UIView) {
        forceAutoLayout()
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func sizeAndCenter(to view: UIView) {
        size(to: view)
        center(in: view)
    }
}

extension UINavigationItem {
    func setPrompt(with message: String, for duration: Double = 3.0) {
        assert(duration > 0.0)
        assert(duration < 10.0)
        self.prompt = message
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.prompt = nil
        }
    }
    
}
