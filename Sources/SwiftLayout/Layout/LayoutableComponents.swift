//
//  LayoutableComponents.swift
//  
//
//  Created by oozoofrog on 2022/01/29.
//

import Foundation
import UIKit

struct LayoutableComponents: Layoutable {
    let layoutables: [Layoutable]
    
    init(_ layoutables: [Layoutable]) {
        self.layoutables = layoutables
    }
    
    func active() -> Layoutable {
        layoutables.forEach({ $0.active() })
        return self
    }
    
    func layoutTree(in parent: UIView) -> LayoutTree {
        LayoutTree(view: parent, subtree: layoutables.map({ $0.layoutTree(in: parent) }))
    }
}
