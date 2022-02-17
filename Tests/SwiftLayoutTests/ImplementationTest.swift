//
//  ImplementationTest.swift
//
//
//  Created by aiden_h on 2022/02/11.
//

import XCTest
@testable import SwiftLayout

final class ImplementationTest: XCTestCase {
    
    var deactivable: Deactivable?
   
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        deactivable = nil
    }
    
    func testTraversal() {
        let root: UIView = UIView().viewTag.root
        let button: UIButton = UIButton().viewTag.button
        let label: UILabel = UILabel().viewTag.label
        let redView: UIView = UIView().viewTag.redView
        let image: UIImageView = UIImageView().viewTag.image
        
        let layout = root {
            redView
            label {
                button
                image
            }
        } as! LayoutImp
        
        var result: [String] = []
        layout.traversal { superLayout, currentLayout in
            let superDescription = superLayout?.view.accessibilityIdentifier ?? "nil"
            let currentDescription = currentLayout.view.accessibilityIdentifier ?? "nil"
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
    
    func testViewStrongReferenceCycle() {
        // given
        class DeinitView: UIView {
            static var deinitCount: Int = 0
            
            deinit {
                Self.deinitCount += 1
            }
        }
        
        class SelfReferenceView: UIView, LayoutBuilding {
            var layout: Layout {
                self {
                    DeinitView().anchors {
                        Anchors.boundary
                    }.subviews {
                        DeinitView()
                    }
                }
            }
            
            var deactivable: Deactivable?
        }
        
        DeinitView.deinitCount = 0
        var view: SelfReferenceView? = SelfReferenceView()
        weak var weakView: UIView? = view
        
        // when
        view?.updateLayout()
        view = nil
        
        // then
        XCTAssertNil(weakView)
        XCTAssertEqual(DeinitView.deinitCount, 2)
    }
    
    func testLayoutFlattening() {
        let root = UIView()
        let child = UIView()
        let friend = UIView()
        
        let layout = root {
            child.anchors {
                Anchors.boundary
            }.subviews {
                friend.anchors {
                    Anchors.boundary
                }
            }
        } as? LayoutImp
        
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.viewInformations.map(\.view), [root, child, friend])
    }
    
    func testLayoutCompare() {
        let root = UIView()
        let child = UIView()
        let friend = UIView()
        
        let f1 = root {
            child
        }
        
        let f2 = root {
           child
        }
        
        let f3 = root {
            child.anchors { Anchors.boundary }
        }
        
        let f4 = root {
            child.anchors { Anchors.boundary }
        }
        
        let f5 = root {
            child.anchors { Anchors.cap }
        }
        
        let f6 = root {
            friend.anchors { Anchors.boundary }
        }
        
        guard
            let f1 = f1 as? LayoutImp,
            let f2 = f2 as? LayoutImp,
            let f3 = f3 as? LayoutImp,
            let f4 = f4 as? LayoutImp,
            let f5 = f5 as? LayoutImp,
            let f6 = f6 as? LayoutImp
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(f1.viewInformations, f2.viewInformations)
        XCTAssertEqual(f1.viewConstraints().weakens, f2.viewConstraints().weakens)
        
        XCTAssertEqual(f3.viewInformations, f4.viewInformations)
        XCTAssertEqual(f3.viewConstraints().weakens, f4.viewConstraints().weakens)
        
        XCTAssertEqual(f4.viewInformations, f5.viewInformations)
        XCTAssertNotEqual(f4.viewConstraints().weakens, f5.viewConstraints().weakens)
        
        XCTAssertNotEqual(f5.viewInformations, f6.viewInformations)
        XCTAssertNotEqual(f5.viewConstraints().weakens, f6.viewConstraints().weakens)
        
    }
    
    func testUpdateLayout() {
        class MockView: UIView {
            var addSubviewCount = 0
            override func addSubview(_ view: UIView) {
                addSubviewCount += 1
                super.addSubview(view)
            }
        }
        
        class LayoutView: UIView, LayoutBuilding {
            var flag = true
            
            let root = MockView().viewTag.root
            let child = UIView().viewTag.child
            let friend = UIView().viewTag.friend
            
            var deactivable: Deactivable?
            
            var layout: Layout {
                root {
                    if flag {
                        child.anchors {
                            Anchors.boundary
                        }
                    } else {
                        friend.anchors {
                            Anchors.boundary
                        }
                    }
                }
            }
        }

        let view = LayoutView()
        let root = view.root
        view.updateLayout()
        
        XCTAssertEqual(root.addSubviewCount, 1)
        
        view.updateLayout()
        
        XCTAssertEqual(root.addSubviewCount, 1)
        XCTAssertEqual(root.findConstraints(items: (view.child, root)).count, 4)
        XCTAssertEqual(view.child.superview, root)
        XCTAssertNil(view.friend.superview)
        
        view.flag.toggle()
        view.updateLayout()
        
        XCTAssertEqual(root.addSubviewCount, 2)
        XCTAssertEqual(root.findConstraints(items: (view.friend, root)).count, 4)
        XCTAssertEqual(view.friend.superview, root)
        XCTAssertNil(view.child.superview)
    }
    
    func testIdentifier() {
        let label = UILabel()
        func create() -> UILabel {
            label
        }
        let root = UIView().viewTag.root
        let deactivation = root {
            create().identifying("label").anchors {
                Anchors.cap
            }
            UIView().identifying("secondView").anchors {
                Anchors(.top).equalTo("label", attribute: .bottom)
                Anchors.shoe
            }
        }.active() as? Deactivation
        
        let labelByIdentifier = deactivation?.viewForIdentifier("label")
        XCTAssertEqual(labelByIdentifier?.accessibilityIdentifier, "label")
        let secondViewByIdentifier = deactivation?.viewForIdentifier("secondView")
        let currents = deactivation?.constraints.constraints ?? []
        let labelConstraints = Set(Anchors.cap.constraints(item: labelByIdentifier!, toItem: root).weakens)
        XCTAssertEqual(currents.intersection(labelConstraints), labelConstraints)
        let secondViewConstraints = Set(Anchors.cap.constraints(item: labelByIdentifier!, toItem: root).weakens)
        XCTAssertEqual(currents.intersection(secondViewConstraints), secondViewConstraints)
        
        let constraintsBetweebViews = Set(Anchors(.top).equalTo(labelByIdentifier!, attribute: .bottom).constraints(item: secondViewByIdentifier!, toItem: labelByIdentifier).weakens)
        XCTAssertEqual(currents.intersection(constraintsBetweebViews), constraintsBetweebViews)
    }
    
    func testIdentifierAnchor() {
        let root = UIView().viewTag.root
        let layout = root.anchors({
            Anchors.boundary.equalTo("label")
        }).subviews {
            UILabel().identifying("label")
        }
        
        guard let layoutImp = layout as? LayoutImp else {
            XCTFail()
            return
        }
        
        deactivable = layoutImp.active()
        
        let label = deactivable?.viewForIdentifier("label")
        

        let viewInfos = layoutImp.viewInformations
        let viewInfoSet = ViewInformationSet(infos: viewInfos)
        let constrains = layoutImp.viewConstraints(viewInfoSet)
        
        XCTAssertNotNil(label)
        XCTAssertEqual(Set(root.constraints.weakens), Set(constrains.weakens))
    }
    
    func testLayoutGuide() {
        let root = UIView().viewTag.root
        let child = UIView().viewTag.child
        
        let layout = root.anchors({
            Anchors.boundary.equalTo(child.safeAreaLayoutGuide)
        }).subviews {
            child
        }
        
        deactivable = layout.active()
        
        print(root.constraints.weakens)
        print(Anchors.boundary.constraints(item: root, toItem: child.safeAreaLayoutGuide).weakens)
        XCTAssertEqual(root.constraints.weakens, Anchors.boundary.constraints(item: root, toItem: child.safeAreaLayoutGuide).weakens)
    }
    
}
    
