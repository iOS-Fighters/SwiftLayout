//
//  Anchors+Core.swift
//  
//
//  Created by oozoofrog on 2022/03/20.
//

import UIKit

extension Anchors {
    
    func constraints(item fromItem: NSObject, toItem: NSObject?) -> [NSLayoutConstraint] {
        constraints(item: fromItem, toItem: toItem, viewInfoSet: nil)
    }
    
    func constraints(item fromItem: NSObject, toItem: NSObject?, viewInfoSet: ViewInformationSet?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        for item in items {
            let from = fromItem
            let attribute = item.attribute
            let relation = item.relation
            let to = item.toItem(toItem, viewInfoSet: viewInfoSet)
            let toAttribute = item.toAttribute(attribute)
            let multiplier = item.multiplier
            let constant = item.constant
            assert(to is UIView || to is UILayoutGuide || to == nil, "to: \(to.debugDescription) is not item")
            let constraint = NSLayoutConstraint(
                item: from,
                attribute: attribute,
                relatedBy: relation,
                toItem: to,
                attribute: toAttribute,
                multiplier: multiplier,
                constant: constant
            )
            constraint.priority = .required
            constraints.append(constraint)
        }
        return constraints
    }
    
    func to(_ relation: NSLayoutConstraint.Relation, to: ConstraintTarget) -> Self {
        func update(_ updateItem: Constraint) -> Constraint {
            let updateItem = updateItem
            updateItem.relation = relation
            updateItem.toItem = to.item
            updateItem.toAttribute = to.attribute
            updateItem.constant = to.constant
            return updateItem
        }
        
        items = items.map(update)
        return self
    }
    
    func union(_ anchors: Anchors) -> Anchors {
        var items = self.items
        items.append(contentsOf: anchors.items)
        return Anchors(items: items)
    }
    
    func formUnion(_ anchors: Anchors) {
        self.items.append(contentsOf: anchors.items)
    }
    
    static func + (lhs: Anchors, rhs: Anchors) -> Anchors {
        lhs.union(rhs)
    }
}
