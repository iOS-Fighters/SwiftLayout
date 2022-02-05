//
//  OptionalLayout.swift
//  
//
//  Created by oozoofrog on 2022/02/06.
//

import Foundation
import UIKit

struct OptionalLayout<L>: Layout where L: Layout {
    let layout: L?
    
    func attachSuperview(_ superview: UIView?) {
        layout?.attachSuperview(superview)
    }
    
    func detachFromSuperview(_ superview: UIView?) {
        layout?.detachFromSuperview(superview)
    }
    
    var hashable: AnyHashable {
        AnyHashable(layout?.hashable)
    }
}
