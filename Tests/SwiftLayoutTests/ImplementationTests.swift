import XCTest
@testable import SwiftLayout
@testable import SwiftLayoutPrinter

/// test cases for api rules except DSL syntax
final class ImplementationTests: XCTestCase {
    
    var window: SLView!
    
    var root = SLView().viewTag.root
    var child = SLView().viewTag.child
    var friend = SLView().viewTag.friend
    
    var activation: Activation?
   
    override func setUpWithError() throws {
        continueAfterFailure = false
        window = SLView(frame: .init(x: 0, y: 0, width: 150, height: 150))
        root = SLView().viewTag.root
        child = SLView().viewTag.child
        friend = SLView().viewTag.friend
        window.addSubview(root)
    }
    
    override func tearDownWithError() throws {
        activation = nil
    }
}

extension ImplementationTests {
    func testLayoutTraversal() {
        let root: SLView = SLView().viewTag.root
        let button: UIButton = UIButton().viewTag.button
        let label: UILabel = UILabel().viewTag.label
        let redView: SLView = SLView().viewTag.redView
        let image: UIImageView = UIImageView().viewTag.image
        
        let layout = root {
            redView
            label {
                button
                image
            }
        }
        
        var result: [String] = []
        for viewInformation in LayoutElements(layout: layout).viewInformations {
            let superDescription = viewInformation.superview?.slIdentifier ?? "nil"
            let currentDescription = viewInformation.view?.slIdentifier ?? "nil"
            let description = "\(superDescription), \(currentDescription)"
            result.append(description)
        }
        
        let expectedResult = [
            "nil, root",
            "root, redView",
            "root, label",
            "label, button",
            "label, image",
        ]
        
        XCTAssertEqual(expectedResult, result)
    }
   
    
    func testLayoutFlattening() {
        let layout = root {
            child.anchors {
                Anchors.allSides()
            }.sublayout {
                friend.anchors {
                    Anchors.allSides()
                }
            }
        }
        
        XCTAssertNotNil(layout)
        XCTAssertEqual(LayoutElements(layout: layout).viewInformations.map(\.view), [root, child, friend])
    }
    
    func testLayoutCompare() {
        let f1 = root {
            child
        }
        let e1 = LayoutElements(layout: f1)

        let f2 = root {
           child
        }
        let e2 = LayoutElements(layout: f2)

        let f3 = root {
            child.anchors { Anchors.allSides() }
        }
        let e3 = LayoutElements(layout: f3)

        let f4 = root {
            child.anchors { Anchors.allSides() }
        }
        let e4 = LayoutElements(layout: f4)

        let f5 = root {
            child.anchors { Anchors.cap() }
        }
        let e5 = LayoutElements(layout: f5)

        let f6 = root {
            friend.anchors { Anchors.allSides() }
        }
        let e6 = LayoutElements(layout: f6)

        XCTAssertEqual(e1.viewInformations, e2.viewInformations)
        XCTAssertEqual(e1.viewConstraints.weakens, e2.viewConstraints.weakens)

        XCTAssertEqual(e3.viewInformations, e4.viewInformations)
        XCTAssertEqual(e3.viewConstraints.weakens, e4.viewConstraints.weakens)

        XCTAssertEqual(e4.viewInformations, e5.viewInformations)
        XCTAssertNotEqual(e4.viewConstraints.weakens, e5.viewConstraints.weakens)

        XCTAssertNotEqual(e5.viewInformations, e6.viewInformations)
        XCTAssertNotEqual(e5.viewConstraints.weakens, e6.viewConstraints.weakens)
    }
    
    func testSetAccessibilityIdentifier() {
        class TestView: SLView {
            let contentView = SLView()
            let nameLabel = UILabel()
        }
        
        let view = TestView()
        IdentifierUpdater.withTypeOfView.update(view)
        
        XCTAssertEqual(view.contentView.slIdentifier, "contentView:\(SLView.self)")
        XCTAssertEqual(view.nameLabel.slIdentifier, "nameLabel:\(UILabel.self)")
        
        class Test2View: TestView {}
        
        let view2 = Test2View()
        IdentifierUpdater.withTypeOfView.update(view2)
        
        XCTAssertEqual(view2.contentView.slIdentifier, "contentView:\(SLView.self)")
        XCTAssertEqual(view2.nameLabel.slIdentifier, "nameLabel:\(UILabel.self)")
    }
    
    func testDontTouchRootViewByDeactive() {
        let root = SLView().viewTag.root
        let red = SLView().viewTag.red
        let old = SLView().viewTag.old
        old.addSubview(root)
        root.translatesAutoresizingMaskIntoConstraints = true
        
        activation = root {
            red.anchors {
                Anchors.allSides()
            }
        }.active()
        
        XCTAssertTrue(root.translatesAutoresizingMaskIntoConstraints)
        
        activation?.deactive()
        activation = nil
        
        XCTAssertEqual(root.superview, old)
    }
    
}

extension ImplementationTests {
    final class IdentifiedView: SLView, Layoutable {
        
        lazy var contentView: SLView = SLView()
        lazy var nameLabel: UILabel = UILabel()
        
        var activation: Activation? 
        
        var layout: some Layout {
            contentView {
                nameLabel
            }
        }
        
        init() {
            super.init(frame: .zero)
            sl.updateLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func testNoAccessibilityIdentifierOption() {
        let view = IdentifiedView()
        XCTAssertEqual(view.contentView.slIdentifier ?? "", "")
        XCTAssertEqual(view.nameLabel.slIdentifier ?? "", "")
    }
    
    func testAccessibilityIdentifierOption() {
        let view = IdentifiedView().updateIdentifiers()
        XCTAssertEqual(view.contentView.slIdentifier, "contentView")
        XCTAssertEqual(view.nameLabel.slIdentifier, "nameLabel")
    }
}

extension ImplementationTests {
    func testIdentifier() {
        let activation = root {
            UILabel().identifying("label").anchors {
                Anchors.cap()
            }
            SLView().identifying("secondView").anchors {
                Anchors(.top).equalTo("label", attribute: .bottom)
                Anchors.shoe()
            }
        }.active()
        
        let label = activation.viewForIdentifier("label")
        XCTAssertNotNil(label)
        XCTAssertEqual(label?.slIdentifier, "label")
        
        let secondView = activation.viewForIdentifier("secondView")
        XCTAssertEqual(secondView?.slIdentifier, "secondView")
        
        let currents = activation.constraints
        let labelConstraints = Set(Anchors.cap().constraints(item: label!, toItem: root).weakens)
        XCTAssertEqual(currents.intersection(labelConstraints), labelConstraints)
        
        let secondViewConstraints = Set(Anchors.cap().constraints(item: label!, toItem: root).weakens)
        XCTAssertEqual(currents.intersection(secondViewConstraints), secondViewConstraints)
        
        let constraintsBetweebViews = Set(Anchors(.top).equalTo(label!, attribute: .bottom).constraints(item: secondView!, toItem: label).weakens)
        XCTAssertEqual(currents.intersection(constraintsBetweebViews), constraintsBetweebViews)
    }
}

extension ImplementationTests {
    func testAnchorConstraint() {
        root.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = Anchors(.top, .leading, .trailing, .bottom).constraints(item: child, toItem: root)
        
        NSLayoutConstraint.activate(constraints)
        
        root.frame = CGRect(origin: .zero, size: .init(width: 200, height: 200))
        root.slLayout()
        XCTAssertEqual(child.frame.size, .init(width: 200, height: 200))
        root.removeConstraints(constraints)
        
        let constraints1 = Anchors(.top, .leading).constraints(item: child, toItem: root)
        let constraints2 = Anchors(.width, .height).equalTo(constant: 98).constraints(item: child, toItem: root)
        
        NSLayoutConstraint.activate(constraints1)
        NSLayoutConstraint.activate(constraints2)
        
        root.slLayout()
        XCTAssertEqual(child.frame.size, .init(width: 98, height: 98))
    }
    
    func testSelfContraint() {
        let superview = SLView().viewTag.superview
        let subview = SLView().viewTag.subview
        
        let constraint = subview.widthAnchor.constraint(equalToConstant: 24)
        
        XCTAssertEqual(constraint.firstItem as? NSObject, subview)
        XCTAssertNil(constraint.secondItem)
        XCTAssertEqual(constraint.firstAttribute, .width)
        XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
        XCTAssertEqual(constraint.constant, 24)
        
        let anchor = Anchors(.width).equalTo(constant: 24).constraints(item: subview, toItem: superview).first!
        
        XCTAssertEqual(anchor.firstItem as? NSObject, subview)
        XCTAssertNil(anchor.secondItem)
        XCTAssertEqual(anchor.firstAttribute, .width)
        XCTAssertEqual(anchor.secondAttribute, .notAnAttribute)
        XCTAssertEqual(anchor.constant, 24)
    }
    
    func testAnchorsBuilder() {
        func build(@AnchorsBuilder _ build: () -> Anchors) -> Anchors {
            build()
        }
        
        let anchors: Anchors = build {
            Anchors(.top).equalTo(constant: 12.0)
            Anchors(.leading).equalTo(constant: 13.0)
            Anchors(.trailing).equalTo(constant: -13.0)
            Anchors(.bottom)
        }
        
        child.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(child)
        
        let constraint = anchors.constraints(item: child, toItem: root, viewInfoSet: nil)
        XCTAssertEqual(constraint.count, 4)
    }
    
    func testIgnoreAnchorsDuplication() {
        root {
            child.anchors {
                Anchors.allSides()
                Anchors.cap()
                Anchors.shoe()
                Anchors(.height)
                Anchors(.width)
                Anchors(.width)
            }
        }.finalActive()
        
        let expect = """
        root {
            child.anchors {
                Anchors(.top, .bottom, .leading, .trailing, .width, .height)
            }
        }
        """
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect.tabbed)
    }
    
    func testIgnoreAnchorsDuplication2() {
        root {
            child.anchors {
                Anchors.cap()
                Anchors(.height).equalTo(constant: 44)
                Anchors(.height).equalTo(constant: 44)
            }
        }.finalActive()
        
        let expect = """
        root {
            child.anchors {
                Anchors(.top, .leading, .trailing)
                Anchors(.height).equalTo(constant: 44.0)
            }
        }
        """
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect.tabbed)
    }
    
    func testRules() {
        let root = SLView().viewTag.root
        root.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(root)
        let child = SLView().viewTag.child
        let friend = SLView().viewTag.friend
        
        enum TestCase {
            case topEqualToNameless
            case topEqualToSuper
            case topEqualToSuperWithConstant
            case topGreaterThanOrEqualToNameless
            case topGreaterThanOrEqualToSuperWithConstant
            case topGreaterThanOrEqualToSuper
            case topLessThanOrEqualToNameless
            case topLessThanOrEqualToSuper
            case topLessThanOrEqualToSuperWithConstant
            
            case topOfFriendEqualToBottomOfChild
            case widthOfFriendEqualToNameless
            case widthOfFriendEqualToSuper
            case widthOfFriendEqualToChild
            case widthOfFriendEqualToHeightOfChild
            case widthOfFriendEqualToConstant
            case widthOfFriendEqualToChildWithConstant
        }
        
        var test = TestCase.topEqualToNameless
        @LayoutBuilder
        func layout() -> Layout {
            root {
                child.anchors {
                    switch test {
                    case .topEqualToNameless:
                        Anchors(.top)
                    case .topEqualToSuper:
                        Anchors(.top).equalTo(root)
                    case .topEqualToSuperWithConstant:
                        Anchors(.top).equalTo(root, constant: 78.0)
                    case .topGreaterThanOrEqualToNameless:
                        Anchors(.top).greaterThanOrEqualTo()
                    case .topGreaterThanOrEqualToSuper:
                        Anchors(.top).greaterThanOrEqualTo(root)
                    case .topGreaterThanOrEqualToSuperWithConstant:
                        Anchors(.top).greaterThanOrEqualTo(root, constant: 78.0)
                    case .topLessThanOrEqualToNameless:
                        Anchors(.top).lessThanOrEqualTo()
                    case .topLessThanOrEqualToSuper:
                        Anchors(.top).lessThanOrEqualTo(root)
                    case .topLessThanOrEqualToSuperWithConstant:
                        Anchors(.top).lessThanOrEqualTo(root, constant: 78.0)
                    default:
                        Anchors.cap()
                    }
                }
                friend.anchors {
                    switch test {
                    case .topOfFriendEqualToBottomOfChild:
                        Anchors(.top).equalTo(child, attribute: .bottom)
                        Anchors.shoe()
                    case .widthOfFriendEqualToNameless:
                        Anchors(.width)
                        Anchors.shoe()
                    case .widthOfFriendEqualToSuper:
                        Anchors(.width).equalTo(root)
                        Anchors.shoe()
                    case .widthOfFriendEqualToChild:
                        Anchors(.width).equalTo(child)
                        Anchors.shoe()
                    case .widthOfFriendEqualToHeightOfChild:
                        Anchors(.width).equalTo(child, attribute: .height)
                        Anchors.shoe()
                    case .widthOfFriendEqualToConstant:
                        Anchors(.width).equalTo(constant: 78.0)
                        Anchors.shoe()
                    case .widthOfFriendEqualToChildWithConstant:
                        Anchors(.width).equalTo(child, constant: 78.0)
                        Anchors(.leading, .bottom)
                    default:
                        Anchors.shoe()
                    }
                }
            }
        }
        
        context("top equal to nameless") {
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .equal).count, 1)
        }

        context("top equal to super") {
            test = .topEqualToSuper
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .equal).count, 1)
        }

        context("top equal to super with constant of 78.0") {
            test = .topEqualToSuperWithConstant
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .equal, constant: 78.0).count, 1)
        }
        
        context("top greater than or equal to nameless") {
            test = .topGreaterThanOrEqualToNameless
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .greaterThanOrEqual).count, 1)
        }
        
        context("top greater than or equal to nameless with constant of 78.0") {
            test = .topGreaterThanOrEqualToSuperWithConstant
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .greaterThanOrEqual, constant: 78.0).count, 1)
        }

        context("top greater than or equal to super") {
            test = .topGreaterThanOrEqualToSuper
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .greaterThanOrEqual).count, 1)
        }

        context("top less than or equal to nameless") {
            test = .topLessThanOrEqualToNameless
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .lessThanOrEqual).count, 1)
        }

        context("top less than or equal to super") {
            test = .topLessThanOrEqualToSuper
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .lessThanOrEqual).count, 1)
        }
        
        context("top less than or equal to super with constant of 78.0") {
            test = .topLessThanOrEqualToSuperWithConstant
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (child, root), attributes: (.top, .top), relation: .lessThanOrEqual, constant: 78.0).count, 1)
        }
        
        context("top of friend equal to bottom of child") {
            test = .topOfFriendEqualToBottomOfChild
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, child), attributes: (.top, .bottom), relation: .equal).count, 1)
        }
        
        context("top of friend equal to bottom of child") {
            test = .topOfFriendEqualToBottomOfChild
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, child), attributes: (.top, .bottom), relation: .equal).count, 1)
        }
        
        context("width of friend equal to width of nameless") {
            test = .widthOfFriendEqualToNameless
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, root), attributes: (.width, .width), relation: .equal).count, 1)
        }
        
        context("width of friend equal to width of super") {
            test = .widthOfFriendEqualToSuper
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, root), attributes: (.width, .width), relation: .equal).count, 1)
        }
        
        context("width of friend equal to width of child") {
            test = .widthOfFriendEqualToChild
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, child), attributes: (.width, .width), relation: .equal).count, 1)
        }
        
        context("width of friend equal to height of child") {
            test = .widthOfFriendEqualToHeightOfChild
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, child), attributes: (.width, .height), relation: .equal).count, 1)
        }
        
        context("width of friend equal to constant of 78.0") {
            test = .widthOfFriendEqualToConstant
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, nil), attributes: (.width, .notAnAttribute), relation: .equal, constant: 78.0).count, 1)
        }
        
        context("width of friend equal to child with constant of 78.0") {
            test = .widthOfFriendEqualToChildWithConstant
            activation = layout().active()
            XCTAssertEqual(root.findConstraints(items: (friend, child), attributes: (.width, .width), relation: .equal, constant: 78.0).count, 1)
        }
    }
    
}

extension ImplementationTests {
    func testFinalActive() {
        let root = SLView().viewTag.root
        let cap = SLView().viewTag.cap
        let shoe = SLView().viewTag.shoe
        
        root {
            cap.anchors {
                Anchors.cap()
            }
            shoe.anchors {
                Anchors.shoe()
            }
        }.finalActive()
        
        let expect = """
        root {
            cap.anchors {
                Anchors(.top, .leading, .trailing)
            }
            shoe.anchors {
                Anchors(.bottom, .leading, .trailing)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect)
    }
}

// MARK: - Anchors only
extension ImplementationTests {
    func testAnchorsOnly() {
        let fixedView = SLView(frame: .init(x: 0, y: 0, width: 120, height: 120))
        fixedView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(fixedView)
        fixedView.anchors {
            Anchors(.width, .height).equalTo(constant: 24.0)
        }.finalActive()
        
        XCTAssertEqual(SwiftLayoutPrinter(fixedView, tags: [fixedView: "fixedView"]).print(), """
        fixedView.anchors {
            Anchors(.width, .height).equalTo(constant: 24.0)
        }
        """.tabbed)
    }
    
    func testConveniencesOfAnchors() {
        let fixedView = SLView().viewTag.fixedView
        fixedView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(fixedView)
        fixedView.anchors {
            Anchors.size(length: 32.0)
        }.finalActive()
        
        let size = fixedView.systemLayoutSizeFitting(.zero)
        XCTAssertEqual(size, .init(width: 32.0, height: 32.0))
    }
}

// MARK: - Decorations
extension ImplementationTests {
    
    func testFeatureCompose() {
        activation = root.config({ root in
            root.backgroundColor = .yellow
        }).identifying("root").anchors({ }).sublayout {
            UILabel().config({ label in
                label.text = "hello"
            }).identifying("child").anchors {
                Anchors.allSides()
            }
        }.active()
        
        let expect = """
        root {
            child.anchors {
                Anchors(.top, .bottom, .leading, .trailing)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect)
    }
    
    func testFeatureComposeComplex() {
        activation = root.config({ root in
            root.backgroundColor = .yellow
        }).sublayout {
            UILabel().config { label in
                label.text = "HELLO"
            }.identifying("hellolabel").anchors {
                Anchors.cap()
            }.sublayout {
                SLView().identifying("lastview").anchors {
                    Anchors.allSides()
                }
            }
            UIButton().identifying("button").anchors {
                Anchors.shoe()
            }
        }.active()
        
        let expect = """
        root {
            hellolabel.anchors {
                Anchors(.top, .leading, .trailing)
            }.sublayout {
                lastview.anchors {
                    Anchors(.top, .bottom, .leading, .trailing)
                }
            }
            button.anchors {
                Anchors(.bottom, .leading, .trailing)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(options: .onlyIdentifier), expect)
    }
    
    func testFeatureComposeComplexWithAnimationHandling() {
        activation = root.config({ root in
            root.backgroundColor = .yellow
        }).sublayout {
            UILabel().config { label in
                label.text = "HELLO"
            }.identifying("hellolabel").anchors {
                Anchors.cap()
            }.sublayout {
                SLView().identifying("lastview").anchors {
                    Anchors.allSides()
                }
            }
            UIButton().identifying("button").anchors {
                Anchors.shoe()
            }
        }.active()
        
        let expect = """
        root {
            hellolabel.anchors {
                Anchors(.top, .leading, .trailing)
            }.sublayout {
                lastview.anchors {
                    Anchors(.top, .bottom, .leading, .trailing)
                }
            }
            button.anchors {
                Anchors(.bottom, .leading, .trailing)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(options: .onlyIdentifier), expect)
    }

}

// MARK: - LayoutProperty
extension ImplementationTests {
    
    func testLayoutProperty() {
        let test = TestView().viewTag.test
        
        XCTAssertEqual(test.trueView.superview, test)
        XCTAssertNil(test.falseView.superview)
        
        test.flag = false
        XCTAssertEqual(test.falseView.superview, test)
        XCTAssertNil(test.trueView.superview)
    }
    
    private class TestView: SLView, Layoutable {
        
        @LayoutProperty var flag = true
        
        var trueView = SLView().viewTag.true
        var falseView = SLView().viewTag.false
        
        var activation: Activation?
        
        var layout: some Layout {
            self {
                if flag {
                    trueView
                } else {
                    falseView
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            sl.updateLayout()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sl.updateLayout()
        }
    }
}
