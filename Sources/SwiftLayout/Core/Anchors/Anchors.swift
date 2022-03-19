//
//  Anchor.swift
//  
//
//  Created by oozoofrog on 2022/02/08.
//

import UIKit

///
/// type of ``AnchorsBuilder`` for auto layout constraint.
///
/// ```swift
/// let parent = UIView()
/// let child = UIView()
/// parent {
///     child.anchors {
///         // constraints(top, bottom, leading, trailing) of child
///         // equal to
///         // constraints(top, bottom, leading, trailing) of parent
///         Anchors.allSides()
///     }
/// }
/// ```
public final class Anchors {
    
    var items: [Constraint] = []
    
    /// initialize and return new Anchors with array of **NSLayoutConstraint.Attribute**
    ///
    /// - Parameter attributes: variadic of **NSLayoutConstraint.Attribute**
    public convenience init(_ attributes: NSLayoutConstraint.Attribute...) {
        let items = attributes.map { Anchors.Constraint(attribute: $0) }
        self.init(items: items)
    }
    
    /// initialize and return new Anchors with array of **NSLayoutConstraint.Attribute**
    ///
    /// - Parameter attributes: array of **NSLayoutConstraint.Attribute**
    public convenience init(_ attributes: [NSLayoutConstraint.Attribute]) {
        let items = attributes.map { Anchors.Constraint(attribute: $0) }
        self.init(items: items)
    }
    
    init(items: [Anchors.Constraint] = []) {
        self.items = items
    }
}

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
            var updateItem = updateItem
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
        items.append(contentsOf: anchors.items)
        return self
    }
    
    static func + (lhs: Anchors, rhs: Anchors) -> Anchors {
        lhs.union(rhs)
    }
}

extension Anchors {

    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func equalTo(constant: CGFloat) -> Self {
        to(.equal, to: .init(item: .deny, attribute: nil, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo(constant: CGFloat = .zero) -> Self {
        to(.greaterThanOrEqual, to: .init(item: .deny, attribute: nil, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo(constant: CGFloat = .zero) -> Self {
        to(.lessThanOrEqual, to: .init(item: .deny, attribute: nil, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Returns: ``Anchors``
    ///
    public func equalTo<I>(_ toItem: I) -> Self where I: ConstraintableItem {
        to(.equal, to: .init(item: toItem, attribute: nil, constant: .zero))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo<I>(_ toItem: I) -> Self where I: ConstraintableItem {
        to(.greaterThanOrEqual, to: .init(item: toItem, attribute: nil, constant: .zero))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo<I>(_ toItem: I) -> Self where I: ConstraintableItem {
        to(.lessThanOrEqual, to: .init(item: toItem, attribute: nil, constant: .zero))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter attribute: Represents the `secondAttribute` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func equalTo<I>(_ toItem: I, attribute: NSLayoutConstraint.Attribute) -> Self where I: ConstraintableItem {
        to(.equal, to: .init(item: toItem, attribute: attribute, constant: .zero))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter attribute: Represents the `secondAttribute` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo<I>(_ toItem: I, attribute: NSLayoutConstraint.Attribute) -> Self where I: ConstraintableItem {
        to(.greaterThanOrEqual, to: .init(item: toItem, attribute: attribute, constant: .zero))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter attribute: Represents the `secondAttribute` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo<I>(_ toItem: I, attribute: NSLayoutConstraint.Attribute) -> Self where I: ConstraintableItem {
        to(.lessThanOrEqual, to: .init(item: toItem, attribute: attribute, constant: .zero))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func equalTo<I>(_ toItem: I, constant: CGFloat) -> Self where I: ConstraintableItem {
        to(.equal, to: .init(item: toItem, attribute: nil, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo<I>(_ toItem: I, constant: CGFloat) -> Self where I: ConstraintableItem {
        to(.greaterThanOrEqual, to: .init(item: toItem, attribute: nil, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo<I>(_ toItem: I, constant: CGFloat) -> Self where I: ConstraintableItem {
        to(.lessThanOrEqual, to: .init(item: toItem, attribute: nil, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter attribute: Represents the `secondAttribute` property of `NSLayoutConstraint`.
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func equalTo<I>(_ toItem: I, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> Self where I: ConstraintableItem {
        to(.equal, to: .init(item: toItem, attribute: attribute, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter attribute: Represents the `secondAttribute` property of `NSLayoutConstraint`.
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo<I>(_ toItem: I, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> Self where I: ConstraintableItem {
        to(.greaterThanOrEqual, to: .init(item: toItem, attribute: attribute, constant: constant))
    }
    
    ///
    /// Set constraint attributes of ``Anchors``
    ///
    /// - Parameter toItem: Represents the `secondItem` property of `NSLayoutConstraint`. It will be UIView, UILayoutGuide, or identifier String.
    /// - Parameter attribute: Represents the `secondAttribute` property of `NSLayoutConstraint`.
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo<I>(_ toItem: I, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> Self where I: ConstraintableItem {
        to(.lessThanOrEqual, to: .init(item: toItem, attribute: attribute, constant: constant))
    }
    
    ///
    /// Set the `constraint` of ``Anchors``
    ///
    /// - Parameter constant: Represents the `constant` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func setConstant(_ constant: CGFloat) -> Self {
        for i in 0..<items.count {
            items[i].constant = constant
        }
        return self
    }
    
    ///
    /// Set the `multiplier` of ``Anchors``
    ///
    /// - Parameter multiplier: Represents the `multiplier` property of `NSLayoutConstraint`.
    /// - Returns: ``Anchors``
    ///
    public func setMultiplier(_ multiplier: CGFloat) -> Self {
        for i in 0..<items.count {
            items[i].multiplier = multiplier
        }
        return self
    }
}

extension Anchors {
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func equalTo(_ layoutAnchor: NSLayoutXAxisAnchor) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.equal, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func equalTo(_ layoutAnchor: NSLayoutYAxisAnchor) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.equal, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func equalTo(_ layoutAnchor: NSLayoutDimension) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.equal, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo(_ layoutAnchor: NSLayoutXAxisAnchor) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.greaterThanOrEqual, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo(_ layoutAnchor: NSLayoutYAxisAnchor) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.greaterThanOrEqual, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func greaterThanOrEqualTo(_ layoutAnchor: NSLayoutDimension) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.greaterThanOrEqual, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo(_ layoutAnchor: NSLayoutXAxisAnchor) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.lessThanOrEqual, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo(_ layoutAnchor: NSLayoutYAxisAnchor) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.lessThanOrEqual, to: target)
    }
    
    ///
    /// Set constraint attributes of ``Anchors`` with `NSLayoutAnchor`
    ///
    /// - Parameter layoutAnchor: A layout anchor from a `UIView` or `UILayoutGuide` object.
    /// - Returns: ``Anchors``
    ///
    public func lessThanOrEqualTo(_ layoutAnchor: NSLayoutDimension) -> Self {
        let target = constraintTargetWithConstant(layoutAnchor)
        return to(.lessThanOrEqual, to: target)
    }
    
    private func constraintTargetWithConstant(_ layoutAnchor: NSLayoutXAxisAnchor) -> Anchors.ConstraintTarget {
        targetFromConstraint(UIView().leadingAnchor.constraint(equalTo: layoutAnchor))
    }
    
    private func constraintTargetWithConstant(_ layoutAnchor: NSLayoutYAxisAnchor) -> Anchors.ConstraintTarget {
        targetFromConstraint(UIView().topAnchor.constraint(equalTo: layoutAnchor))
    }
    
    private func constraintTargetWithConstant(_ layoutAnchor: NSLayoutDimension) -> Anchors.ConstraintTarget {
        targetFromConstraint(UIView().widthAnchor.constraint(equalTo: layoutAnchor))
    }
    
    private func targetFromConstraint(_ constraint: NSLayoutConstraint) -> Anchors.ConstraintTarget {
        if let object = constraint.secondItem as? NSObject {
            return .init(item: .object(object), attribute: constraint.secondAttribute, constant: .zero)
        } else {
            return .init(item: .transparent, attribute: constraint.secondAttribute, constant: .zero)
        }
    }
}

extension Anchors {
    struct ConstraintTarget {
        init<I>(item: I?, attribute: NSLayoutConstraint.Attribute?, constant: CGFloat) where I: ConstraintableItem {
            self.item = ItemFromView(item).item
            self.attribute = attribute
            self.constant = constant
        }
        
        init(item: Item = .transparent, attribute: NSLayoutConstraint.Attribute?, constant: CGFloat) {
            self.item = item
            self.attribute = attribute
            self.constant = constant
        }
        
        let item: Item
        let attribute: NSLayoutConstraint.Attribute?
        let constant: CGFloat
    }
    
    struct Constraint: Hashable, CustomStringConvertible {
        var attribute: NSLayoutConstraint.Attribute
        var relation: NSLayoutConstraint.Relation = .equal
        var toItem: Item = .transparent
        var toAttribute: NSLayoutConstraint.Attribute?
        
        var constant: CGFloat = 0.0
        var multiplier: CGFloat = 1.0
        
        func toItem(_ toItem: NSObject?, viewInfoSet: ViewInformationSet? = nil) -> NSObject? {
            switch self.toItem {
            case let .object(object):
                return object
            case let .identifier(identifier):
                return viewInfoSet?[identifier] ?? toItem
            case .transparent:
                return toItem
            case .deny:
                switch attribute {
                case .width, .height:
                    return nil
                default:
                    return toItem
                }
            }
        }
        
        func toAttribute(_ attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint.Attribute {
            return toAttribute ?? attribute
        }
        
        var description: String {
            var elements: [String] = []
            elements.append(".\(attribute.description)")
            elements.append(relation.shortDescription)
            if let itemDescription = toItem.shortDescription {
                elements.append("\(itemDescription).\((toAttribute ?? attribute).description)")
            } else if attribute != .height && attribute != .width {
                elements.append("\("superview").\((toAttribute ?? attribute).description)")
            }
            
            if multiplier != 1.0 {
                elements.append("x \(multiplier)")
            }
            
            if constant < 0 {
                elements.append("- \(-constant)")
            } else if constant > 0 {
                elements.append("+ \(constant)")
            }
            
            return elements.joined(separator: " ")
        }
    }
    
    enum Item: Hashable {
        case object(NSObject)
        case identifier(String)
        case transparent
        case deny
        
        init(_ item: Any?) {
            if let string = item as? String {
                self = .identifier(string)
            } else if let object = item as? NSObject {
                self = .object(object)
            } else {
                self = .transparent
            }
        }
        
        var shortDescription: String? {
            switch self {
            case .object(let object):
                if let view = object as? UIView {
                    return view.tagDescription
                } else if let guide = object as? UILayoutGuide {
                    return guide.detailDescription ?? "unknown"
                } else {
                    return "unknown"
                }
            case .identifier(let string):
                return string
            case .transparent:
                return "superview"
            case .deny:
                return nil
            }
        }
    }
}
