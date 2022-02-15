//
//  Constraint.swift
//  
//
//  Created by oozoofrog on 2022/02/04.
//

import Foundation
import UIKit

public protocol Constraint {
    func constraints(item: NSObject, toItem: NSObject?, identifiers: ViewIdentifiers?) -> [NSLayoutConstraint]
    func constraints(item: NSObject, toItem: NSObject?) -> [NSLayoutConstraint]
}

extension Array: Constraint where Element == Constraint {
    public func constraints(item: NSObject, toItem: NSObject?, identifiers: ViewIdentifiers?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        for constraint in self {
            constraints.append(contentsOf: constraint.constraints(item: item, toItem: toItem, identifiers: identifiers))
        }
        return constraints
    }
    
    public func constraints(item: NSObject, toItem: NSObject?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        for constraint in self {
            constraints.append(contentsOf: constraint.constraints(item: item, toItem: toItem))
        }
        return constraints
    }
}
