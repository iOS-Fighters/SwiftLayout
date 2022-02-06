//
//  LayoutViewContainable.swift
//  
//
//  Created by oozoofrog on 2022/02/06.
//

import Foundation
import UIKit

public protocol LayoutViewContainable: LayoutContainable {
    var view: UIView { get }
}

public extension LayoutViewContainable {
    func attachSuperview(_ superview: UIView?) {
        superview?.addSubview(self.view)
        for layout in layouts {
            layout.attachSuperview(self.view)
        }
    }
    func detachFromSuperview(_ superview: UIView?) {
        if let superview = superview, self.view.superview == superview {
            self.view.removeFromSuperview()
        }
        for layout in layouts {
            layout.detachFromSuperview(self.view)
        }
    }
    
    var hashable: AnyHashable {
        AnyHashable(layouts.map(\.hashable) + [self.view.hashable])
    }
}
