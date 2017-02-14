//
//  SwiftLibraryExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 2/14/17.
//
//

import Foundation

public extension Dictionary {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var copy = self
        dictionary.forEach {
            copy.updateValue($1, forKey: $0)
        }
        return copy
    }
}

public extension String {
    
    var isOnlyWhiteSpace: Bool {
        let whitespaceSet = CharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespaceSet).isEmpty
    }
    
}
