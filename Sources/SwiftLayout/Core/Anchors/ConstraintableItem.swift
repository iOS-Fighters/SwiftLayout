//
//  ConstraintItem.swift
//  
//
//  Created by oozoofrog on 2022/02/14.
//

import Foundation

final class ItemFromView<View> where View: ConstraintableItem {
    internal init(_ view: View?) {
        self.view = view
    }
    
    let view: View?
    
    var item: Anchors.Item {
        guard let view = view else {
            return .transparent
        }
        return Anchors.Item(view)
    }
}

public protocol ConstraintableItem {}
extension SLView: ConstraintableItem {}
extension SLLayoutGuide: ConstraintableItem {}
extension String: ConstraintableItem {}
