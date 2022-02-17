//
//  DSLIntentionTests.swift
//  
//
//  Created by oozoofrog on 2022/02/08.
//

import Foundation
import XCTest
import SwiftLayout
import UIKit

///
/// 이 테스트 케이스에서는 구현이 아닌 인터페이스 혹은
/// 구현을 테스트 합니다.
final class DSLTests: XCTestCase {
    
    var deactivable: Deactivable?
    
    var view: LayoutHostingView!
    var root: UIView!
    var red: UIView!
    var blue: UIView!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        root = UIView().viewTag.root
        red = UIView().viewTag.red
        blue = UIView().viewTag.blue
    }
    
    override func tearDownWithError() throws {
    }
    
    func testDontTouchRootViewByDeactivation() {
        let old = UIView().viewTag.old
        old.addSubview(root)
        root.translatesAutoresizingMaskIntoConstraints = true
        
        view = LayoutHostingView(root {
            red.anchors {
                Anchors.boundary
            }
        })
        
        XCTAssertTrue(root.translatesAutoresizingMaskIntoConstraints)
        view.deactivable?.deactive()
        
        XCTAssertEqual(root.superview, old)
    }
    
    func testAnchors() {
     
        deactivable = root {
            red.anchors {
                Anchors.boundary
            }
        }.active()
        
        XCTAssertEqual(red.superview, root)
        for attribute in [NSLayoutConstraint.Attribute.top, .leading, .trailing, .bottom] {
            let reds = root.findConstraints(items: (red, root),
                                            attributes: (attribute, attribute))
            XCTAssertEqual(reds.count, 1, reds.debugDescription)
        }
    }
    
    func testLayoutAfterAnchors() {
        view = LayoutHostingView(root {
            red.anchors {
                Anchors.boundary
            }.subviews {
                blue.anchors {
                    Anchors.boundary
                }
            }
        })
        
        XCTAssertEqual(red.superview, root)
        XCTAssertEqual(blue.superview, red)
        for attribute in [NSLayoutConstraint.Attribute.top, .leading, .trailing, .bottom] {
            let reds = root.findConstraints(items: (red, root),
                                            attributes: (attribute, attribute))
            XCTAssertEqual(reds.count, 1, reds.debugDescription)
            
            let blues = root.findConstraints(items: (blue, red),
                                             attributes: (attribute, attribute))
            XCTAssertEqual(blues.count, 1, blues.debugDescription)
        }
    }
    
    func testAnchorsEitherTrue() {
        
        let toggle = true
        view = LayoutHostingView(root {
            red.anchors {
                if toggle {
                    Anchors.cap
                    Anchors(.bottom).equalTo(blue, attribute: .top)
                } else {
                    Anchors.shoe
                    Anchors(.top).equalTo(blue, attribute: .bottom)
                }
            }
            blue.anchors {
                if toggle {
                    Anchors.shoe
                } else {
                    Anchors.cap
                }
            }
        })

        XCTAssertEqual(root.constraints.count, 7)

        XCTAssertEqual(root.findConstraints(items: (red, root), attributes: (.top, .top)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (red, root), attributes: (.leading, .leading)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (red, root), attributes: (.trailing, .trailing)).count, 1)

        XCTAssertEqual(root.findConstraints(items: (blue, root), attributes: (.bottom, .bottom)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (blue, root), attributes: (.leading, .leading)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (blue, root), attributes: (.trailing, .trailing)).count, 1)
    }
    
    func testAnchorsEitherFalse() {
        
        let toggle = false
        view = LayoutHostingView(root {
            red.anchors {
                if toggle {
                    Anchors.cap
                    Anchors(.bottom).equalTo(blue, attribute: .top)
                } else {
                    Anchors.shoe
                    Anchors(.top).equalTo(blue, attribute: .bottom)
                }
            }
            blue.anchors {
                if toggle {
                    Anchors.shoe
                } else {
                    Anchors.cap
                }
            }
        })

        XCTAssertEqual(root.constraints.count, 7)

        XCTAssertEqual(root.findConstraints(items: (blue, root), attributes: (.top, .top)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (blue, root), attributes: (.leading, .leading)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (blue, root), attributes: (.trailing, .trailing)).count, 1)

        XCTAssertEqual(root.findConstraints(items: (red, root), attributes: (.bottom, .bottom)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (red, root), attributes: (.leading, .leading)).count, 1)
        XCTAssertEqual(root.findConstraints(items: (red, root), attributes: (.trailing, .trailing)).count, 1)
    }
    
    func testConstraintDSL() {
        view = LayoutHostingView(root {
            red.anchors {
                Anchors(.top, .leading, .bottom)
                Anchors(.trailing).equalTo(blue, attribute: .leading)
            }
            blue.anchors {
                Anchors(.top, .trailing, .bottom)
            }
        })
        
        // root가 constraint를 다 가져감
        XCTAssertEqual(root.constraints.count, 7)
        for attr in [NSLayoutConstraint.Attribute.top, .leading, .bottom] {
            XCTAssertNotNil(root.findConstraints(items: (red, root), attributes: (attr, attr)).first)
        }
        XCTAssertNotNil(root.findConstraints(items: (red, blue), attributes: (.trailing, .leading)).first)
        for attr in [NSLayoutConstraint.Attribute.top, .trailing, .bottom] {
            XCTAssertNotNil(root.findConstraints(items: (blue, root), attributes: (attr, attr)).first)
        }
    }
    
    func testLayoutInConstraint() {
        view = LayoutHostingView(root {
            red.anchors {
                Anchors(.top, .bottom, .leading, .trailing)
            }.subviews {
                blue.anchors {
                    Anchors(.centerX, .centerY)
                }
            }
        })
        
        XCTAssertEqual(blue.superview, red)
        XCTAssertEqual(red.superview, root)
        
        for attr in [NSLayoutConstraint.Attribute.top, .leading, .trailing, .bottom] {
            XCTAssertNotNil(root.findConstraints(items: (red, root), attributes: (attr, attr)).first)
        }
        XCTAssertNotNil(root.findConstraints(items: (blue, red), attributes: (.centerX, .centerX)).first)
        XCTAssertNotNil(root.findConstraints(items: (blue, red), attributes: (.centerY, .centerY)).first)
    }
    
    func testAnchorsFromNSLayoutAnchor() {
        view = LayoutHostingView(root {
            red.anchors {
                Anchors.cap
                red.bottomAnchor.constraint(equalTo: blue.topAnchor)
            }
            blue.anchors {
                Anchors.shoe
            }
        })
        
        // root가 constraint를 다 가져감
        XCTAssertEqual(root.constraints.count, 7)
        for attr in [NSLayoutConstraint.Attribute.top, .leading, .trailing] {
            XCTAssertNotNil(root.findConstraints(items: (red, root), attributes: (attr, attr)).first)
        }
        XCTAssertNotNil(root.findConstraints(items: (red, blue), attributes: (.bottom, .top)).first)
        for attr in [NSLayoutConstraint.Attribute.leading, .trailing, .bottom] {
            XCTAssertNotNil(root.findConstraints(items: (blue, root), attributes: (attr, attr)).first)
        }
    }
    
    func testViewLayout() {
        view = LayoutHostingView(root {
            red.anchors {
                Anchors.boundary
            }
        })
        
        root.frame = .init(origin: .zero, size: .init(width: 30, height: 30))
        root.setNeedsLayout()
        root.layoutIfNeeded()

        XCTAssertEqual(root.frame, .init(x: 0, y: 0, width: 30, height: 30))
        XCTAssertEqual(red.frame, .init(x: 0, y: 0, width: 30, height: 30))
    }
    
    func testInitViewInLayout() {
        view = LayoutHostingView(root {
            UILabel().anchors {
                Anchors(.centerX, .centerY)
            }
        })
        
        XCTAssertEqual(root.constraints.count, 2)
    }
    
    func testForIn() {
        let views: [UILabel] = (0..<10).map(\.description).map({
            let label = UILabel()
            label.text = $0.description
            return label
        })
        
        let root = UIView().viewTag.root
        view = LayoutHostingView(root {
            for view in views {
                view
            }
        })
        
        XCTAssertEqual(root.subviews.count, views.count)
        XCTAssertEqual(root.subviews, views)
    }
    
    func testEither() {
        let root = UIView().viewTag.root
        let friendA = UIView().viewTag.friendA
        let friendB = UIView().viewTag.friendB
        
        var chooseA = true
        deactivable = root {
            if chooseA {
                friendA
            } else {
                friendB
            }
        }.active()
        
        XCTAssertEqual(friendA.superview, root)
        XCTAssertNotEqual(friendB.superview, root)
        
        chooseA = false
        
        deactivable = root {
            if chooseA {
                friendA
            } else {
                friendB
            }
        }.active()
        
        XCTAssertNotEqual(friendA.superview, root)
        XCTAssertEqual(friendB.superview, root)
    }
    
    func testAnchorsOfDimensionToItem() {
        let root = UIView().viewTag.root
        let child = UIView().viewTag.child
        
        deactivable = root {
            child.anchors {
                Anchors(.top, .leading)
                Anchors(.width, .height)
            }
        }.active()
        
        XCTAssertEqual(root.constraints.count, 4)
        
        root.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        root.setNeedsLayout()
        root.layoutIfNeeded()
        
        XCTAssertEqual(child.bounds.size, .init(width: 100, height: 100))
    }
    
    func testAnchorsOfDimensionToItem2() {
        let root = UIView().viewTag.root
        let child = UIView().viewTag.child
        
        deactivable = root {
            child.anchors {
                Anchors(.top, .leading)
                Anchors(.width, .height).equalTo(constant: 80)
            }
        }.active()
        
        XCTAssertEqual(root.constraints.count, 2)
        XCTAssertEqual(child.constraints.count, 2)
        
        root.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        root.setNeedsLayout()
        root.layoutIfNeeded()
        
        XCTAssertEqual(child.bounds.size, .init(width: 80, height: 80))
    }
    
    func testAnchorsOfDimensionToItem3() {
        let root = UIView().viewTag.root
        let child1 = UIView().viewTag.child2
        let child2 = UIView().viewTag.child2
        
        deactivable = root {
            child1.anchors {
                Anchors(.top, .trailing, .bottom)
                Anchors(.width, .height).equalTo(constant: 80)
            }
            child2.anchors {
                Anchors(.trailing).equalTo(child1, attribute: .leading)
                Anchors(.top, .bottom)
                Anchors(.width, .height).equalTo(constant: 80)
            }
        }.active()
        
        XCTAssertEqual(root.constraints.count, 6)
        XCTAssertEqual(child1.constraints.count, 2)
        XCTAssertEqual(child2.constraints.count, 2)
        
        root.frame = .init(origin: .zero, size: .init(width: 200, height: 80))
        root.setNeedsLayout()
        root.layoutIfNeeded()
        
        XCTAssertEqual(child1.frame.origin, .init(x: 120, y: 0))
        XCTAssertEqual(child1.bounds.size, .init(width: 80, height: 80))
        
        XCTAssertEqual(child2.frame.origin, .init(x: 40, y: 0))
        XCTAssertEqual(child1.bounds.size, .init(width: 80, height: 80))
    }
    
    func testAnchorsOfDimensionToItem4() {
        let root = UIView().viewTag.root
        let child = UIView().viewTag.child
        
        deactivable = root {
            child.anchors {
                Anchors(.top, .leading).equalTo(constant: 20)
                Anchors(.trailing, .bottom).equalTo(constant: -20)
            }
        }.active()
        
        XCTAssertEqual(root.constraints.count, 4)
        
        root.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        root.setNeedsLayout()
        root.layoutIfNeeded()
        print(root.constraints)
        XCTAssertEqual(child.frame.size, .init(width: 60, height: 60))
    }
    
    final class IdentifiedView: UIView, LayoutBuilding {
        
        lazy var contentView: UIView = UIView()
        lazy var nameLabel: UILabel = UILabel()
        
        var deactivable: Deactivable?
        
        var layout: Layout {
            contentView {
                nameLabel
            }
        }
        
        init(_ options: LayoutOptions = []) {
            super.init(frame: .zero)
            updateLayout(options)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func testNoAccessibilityIdentifierOption() {
        let view = IdentifiedView()
        XCTAssertNil(view.contentView.accessibilityIdentifier)
        XCTAssertNil(view.nameLabel.accessibilityIdentifier)
    }
    
    func testAccessibilityIdentifierOption() {
        let view = IdentifiedView(.accessibilityIdentifiers)
        XCTAssertEqual(view.contentView.accessibilityIdentifier, "contentView")
        XCTAssertEqual(view.nameLabel.accessibilityIdentifier, "nameLabel")
    }
}

extension Anchors {
    static var boundary: Anchors { .init(.top, .leading, .trailing, .bottom) }
    static var cap: Anchors { .init(.top, .leading, .trailing) }
    static var shoe: Anchors { .init(.leading, .trailing, .bottom) }
}

extension UIView {
    func findConstraints(items: (NSObject?, NSObject?), attributes: (NSLayoutConstraint.Attribute, NSLayoutConstraint.Attribute)? = nil, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = .zero, multiplier: CGFloat = 1.0) -> [NSLayoutConstraint] {
        var constraints = self.constraints.filter { constraint in
            constraint.isFit(items: items, attributes: attributes, relation: relation, constant: constant, multiplier: multiplier)
        }
        for subview in subviews {
            constraints.append(contentsOf: subview.findConstraints(items: items, attributes: attributes, relation: relation, constant: constant, multiplier: multiplier))
        }
        return constraints
    }
}

extension NSLayoutConstraint {
    func isFit(items: (NSObject?, NSObject?), attributes: (NSLayoutConstraint.Attribute, NSLayoutConstraint.Attribute)? = nil, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = .zero, multiplier: CGFloat = 1.0) -> Bool {
        let item = firstItem as? NSObject
        let toItem = secondItem as? NSObject
        return (item, toItem) == items
        && attributes.flatMap({ $0 == (firstAttribute, secondAttribute) }) ?? true
        && self.relation == relation && self.constant == constant && self.multiplier == multiplier
    }
}

class LayoutHostingView: UIView, LayoutBuilding {
    
    let content: Layout
    
    var layout: Layout {
        content
    }
    
    var deactivable: Deactivable?
    
    init(_ _content: Layout) {
        content = _content
        super.init(frame: .zero)
        updateLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
