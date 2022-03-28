import XCTest
import SwiftLayout

/// test cases for constraint DSL syntax
final class AnchorsDSLTests: XCTestCase {
        
    var root: UIView = UIView().viewTag.root
    var red: UIView = UIView().viewTag.red
    var blue: UIView = UIView().viewTag.blue
    
    var constant: CGFloat = 0.0
    
    var activation: Activation?
    
    override func setUp() {
        root = UIView(frame: .init(x: 0, y: 0, width: 120, height: 120)).viewTag.root
        red = UIView().viewTag.red
        blue = UIView().viewTag.blue
        constant = CGFloat.random(in: -5...5)
        continueAfterFailure = false
    }
    
    override func tearDown() {
        activation = nil
    }
    
    var constantDescription: String {
        if constant < 0 {
            return "- \(abs(constant).description)"
        } else if constant > 0 {
            return "+ \(abs(constant).description)"
        } else {
            return ""
        }
    }
    
}

extension AnchorsDSLTests {
    func testAnchorsEqualToSuperview() {
        let xaxis = ["centerX": Anchors.centerX,
                     "leading": Anchors.leading,
                     "trailing": Anchors.trailing,
                     "left": Anchors.left,
                     "right": Anchors.right]
        for (key, x) in xaxis {
            context("x anchor for \(key) \(constantDescription)") {
                root {
                    red.anchors {
                        x.constant(constant)
                    }
                }.finalActive()
                
                XCTAssertEqual(root.constraints.shortDescription, """
                red.\(key) == root.\(key) \(constantDescription)
                """.descriptions)
            }
        }
        
        let yaxis = ["centerY": Anchors.centerY,
                     "top": Anchors.top,
                     "bottom": Anchors.bottom,
                     "firstBaseline": Anchors.firstBaseline,
                     "lastBaseline": Anchors.lastBaseline]
        for (key, y) in yaxis {
            context("y anchor for \(key) \(constantDescription)") {
                root {
                    red.anchors {
                        y.constant(constant)
                    }
                }.finalActive()
                
                XCTAssertEqual(root.constraints.shortDescription, """
                red.\(key) == root.\(key) \(constantDescription)
                """.descriptions)
            }
        }
        
        let dimensions = ["width": Anchors.width,
                          "height": Anchors.height]
        for (key, dimension) in dimensions {
            context("dimension anchor for \(key) \(constantDescription)") {
                root {
                    red.anchors {
                        dimension.constant(constant)
                    }
                }.finalActive()
                
                XCTAssertEqual(root.constraints.shortDescription, """
                red.\(key) == root.\(key) \(constantDescription)
                """.descriptions)
            }
        }
    }
    
    func testAnchorsLessThanOrEqualToSuperview() {
        let xaxis = ["centerX": Anchors.centerX,
                     "leading": Anchors.leading,
                     "trailing": Anchors.trailing,
                     "left": Anchors.left,
                     "right": Anchors.right]
        for (key, x) in xaxis {
            context("x anchor for \(key) \(constantDescription)") {
                root {
                    red.anchors {
                        x.lessThanOrEqualToSuper().constant(constant)
                    }
                }.finalActive()
                
                XCTAssertEqual(root.constraints.shortDescription, """
                red.\(key) <= root.\(key) \(constantDescription)
                """.descriptions)
            }
        }
        
        let yaxis = ["centerY": Anchors.centerY,
                     "top": Anchors.top,
                     "bottom": Anchors.bottom,
                     "firstBaseline": Anchors.firstBaseline,
                     "lastBaseline": Anchors.lastBaseline]
        for (key, y) in yaxis {
            context("y anchor for \(key) \(constantDescription)") {
                root {
                    red.anchors {
                        y.lessThanOrEqualToSuper().constant(constant)
                    }
                }.finalActive()
                
                XCTAssertEqual(root.constraints.shortDescription, """
                red.\(key) <= root.\(key) \(constantDescription)
                """.descriptions)
            }
        }
        
        let dimensions = ["width": Anchors.width,
                          "height": Anchors.height]
        for (key, dimension) in dimensions {
            context("dimension anchor for \(key) \(constantDescription)") {
                root {
                    red.anchors {
                        dimension.lessThanOrEqualToSuper().constant(constant)
                    }
                }.finalActive()
                
                XCTAssertEqual(root.constraints.shortDescription, """
                red.\(key) <= root.\(key) \(constantDescription)
                """.descriptions)
            }
        }
    }
    
    func testAnchorsInSublayout() {
        root {
            red.anchors {
                Anchors.allSides()
            }.sublayout {
                blue.anchors {
                    Anchors.center().multiplier(0.5)
                }
            }
        }.finalActive()
        
        XCTAssertEqual(root.constraints.shortDescription, """
        red.top == root.top
        red.bottom == root.bottom
        red.leading == root.leading
        red.trailing == root.trailing
        """.descriptions)
        XCTAssertEqual(red.constraints.shortDescription, """
        blue.centerX == red.centerX x 0.5
        blue.centerY == red.centerY x 0.5
        """.descriptions)
    }
    
    func testAnchorsTrueOnly() {
        @LayoutBuilder func layout() -> some Layout {
            root {
                red.anchors {
                    if true {
                        Anchors.allSides()
                    }
                }
            }
        }
        
        layout().finalActive()
        
        XCTAssertEqual(root.constraints.shortDescription, """
        red.top == root.top
        red.bottom == root.bottom
        red.leading == root.leading
        red.trailing == root.trailing
        """.descriptions)
    }
    
    func testAnchorsIF() {
        @LayoutBuilder func layout(_ flag: Bool) -> some Layout {
            root {
                red.anchors {
                    if flag {
                        Anchors.cap()
                    } else {
                        Anchors.shoe()
                    }
                }
            }
        }
        
        context("true") {
            layout(true).finalActive()
            XCTAssertEqual(root.constraints.shortDescription, """
            red.top == root.top
            red.leading == root.leading
            red.trailing == root.trailing
            """.descriptions)
        }
        
        context("false") {
            layout(false).finalActive()
            XCTAssertEqual(root.constraints.shortDescription, """
            red.bottom == root.bottom
            red.leading == root.leading
            red.trailing == root.trailing
            """.descriptions)
        }
    }
    
    func testOptionalAnchors() {
        @LayoutBuilder func layout(_ anchors: AnchorsExpression<AnchorsXAxisAttribute>?) -> some Layout {
            root {
                red.anchors {
                    anchors
                }
            }
        }
        
        context("nil anchors") {
            layout(nil).finalActive()
            XCTAssertEqual(root.constraints.shortDescription, Set())
        }
        
        context("leading anchors") {
            layout(Anchors.leading).finalActive()
            XCTAssertEqual(root.constraints.shortDescription, "red.leading == root.leading".descriptions)
        }
    }
    
    func testOptionalBindingAnchors() {
        @LayoutBuilder func layout(_ anchors: AnchorsExpression<AnchorsXAxisAttribute>?) -> some Layout {
            root {
                red.anchors {
                    if let anchors = anchors {
                        anchors
                    }
                }
            }
        }
        
        context("nil anchors") {
            layout(nil).finalActive()
            XCTAssertEqual(root.constraints.shortDescription, "".descriptions)
        }
        
        context("leading anchors") {
            layout(Anchors.leading).finalActive()
            XCTAssertEqual(root.constraints.shortDescription, "red.leading == root.leading".descriptions)
        }
    }
    
//    func testAnchorsWithForIn() {
//        let attributes: [NSLayoutConstraint.Attribute] = [
//            .top,
//            .bottom,
//            .leading,
//            .trailing
//        ]
//
//        root {
//            red.anchors {
//                for attr in attributes {
//                    Anchors(attr)
//                }
//            }
//        }.finalActive()
//
//        XCTAssertEqual(root.constraints.shortDescription, """
//        red.top == root.top
//        red.bottom == root.bottom
//        red.leading == root.leading
//        red.trailing == root.trailing
//        """.descriptions)
//    }
//
    func testAnchorsFromSeperately() {
        root {
            red.anchors {
                Anchors.cap()
            }
            blue.anchors {
                Anchors.shoe()
            }
            red.anchors {
                Anchors.bottom.equalTo(blue, attribute: .top)
            }
        }.finalActive()
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), """
        root {
            red.anchors {
                Anchors(.top, .leading, .trailing)
                Anchors(.bottom).equalTo(blue, attribute: .top)
            }
            blue.anchors {
                Anchors(.bottom, .leading, .trailing)
            }
        }
        """.tabbed)
    }
    
    func testAnchorsFromLayoutGuide() {
        root.anchors {
            Anchors.allSides(red.safeAreaLayoutGuide)
        }.sublayout {
            red
        }.finalActive()
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), """
        root.anchors {
            Anchors(.top, .bottom, .leading, .trailing).equalTo(red.safeAreaLayoutGuide)
        }.sublayout {
            red
        }
        """.tabbed)
    }
    
    func testAnchorsFromIdentifier() {
        root.anchors {
            Anchors.allSides("label")
        }.sublayout {
            UILabel().identifying("label")
        }.finalActive()
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), """
        root.anchors {
            Anchors(.top, .bottom, .leading, .trailing).equalTo(label)
        }.sublayout {
            label
        }
        """.tabbed)
    }
    
    func testDuplicateAnchorBuilder() {
        root {
            red.anchors {
                Anchors.top.bottom
                Anchors.leading
                Anchors.top.bottom
                Anchors.leading
            }.anchors {
                Anchors.trailing.equalTo(blue, attribute: .leading)
                Anchors.trailing.equalTo(blue, attribute: .leading)
            }
            blue.anchors {
                Anchors.top.bottom
                Anchors.trailing
                Anchors.top.bottom
                Anchors.trailing
            }
        }.finalActive()
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), """
        root {
            red.anchors {
                Anchors(.top, .bottom, .leading)
                Anchors(.trailing).equalTo(blue, attribute: .leading)
            }
            blue.anchors {
                Anchors(.top, .bottom, .trailing)
            }
        }
        """.tabbed)
    }
}

extension AnchorsDSLTests {
    func testAnchorsOfDimensionToItem1() {
        root.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        root {
            red.anchors {
                Anchors.allSides()
            }
        }.finalActive(forceLayout: true)
        
        XCTAssertEqual(root.constraints.shortDescription, """
        red.top == root.top
        red.bottom == root.bottom
        red.leading == root.leading
        red.trailing == root.trailing
        """.descriptions)
        XCTAssertEqual(red.bounds.size, .init(width: 100, height: 100))
    }
    
    func testAnchorsOfDimensionToItem2() {
        root.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        activation = root {
            red.anchors {
                Anchors.bottom
                Anchors.trailing
                Anchors.size(width: 30, height: 30)
            }
        }.active(forceLayout: true)
        
        XCTAssertEqual(root.constraints.shortDescription, """
        red.bottom == root.bottom
        red.trailing == root.trailing
        """.descriptions)
        XCTAssertEqual(red.constraints.shortDescription, """
        red.width == + 30.0
        red.height == + 30.0
        """.descriptions)
        XCTAssertEqual(red.frame, .init(x: 70, y: 70, width: 30, height: 30))
    }
    
    func testConvenience() {
        activation = root {
            red.anchors {
                Anchors.allSides(root)
            }
        }.active()
        
        let expect = """
        root {
            red.anchors {
                Anchors(.top, .bottom, .leading, .trailing)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect)
    }
}

// MARK: - Anchors from UILayoutAnchor
extension AnchorsDSLTests {
    
    func testAnchorsEqualToUILayoutAnchor() {
        activation = root {
            red.anchors {
                Anchors.top.equalTo(root.topAnchor)
                Anchors.leading.equalTo(root.leadingAnchor)
                Anchors.trailing.equalTo(root.trailingAnchor).constant(-14.0)
                Anchors.bottom.equalTo(root.bottomAnchor)
                Anchors.height.equalTo(root.heightAnchor)
                Anchors.centerY.equalTo(root.centerYAnchor)
            }
        }.active()
        
        let expect = """
        root {
            red.anchors {
                Anchors(.top, .bottom, .leading, .height, .centerY)
                Anchors(.trailing).equalTo(constant: -14.0)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect)
    }
    
    func testAnchorsGreaterThanOrEqualToUILayoutAnchor() {
        
        activation = root {
            red.anchors {
                Anchors.top.greaterThanOrEqualTo(root.topAnchor)
                Anchors.leading.greaterThanOrEqualTo(root.leadingAnchor)
                Anchors.trailing.greaterThanOrEqualTo(root.trailingAnchor)
                Anchors.bottom.greaterThanOrEqualTo(root.bottomAnchor).constant(13.0)
                Anchors.width.greaterThanOrEqualTo(root.widthAnchor)
                Anchors.height.greaterThanOrEqualTo(root.heightAnchor)
                Anchors.centerX.greaterThanOrEqualTo(root.centerXAnchor)
                Anchors.centerY.greaterThanOrEqualTo(root.centerYAnchor)
            }
        }.active()
        
        let expect = """
        root {
            red.anchors {
                Anchors(.top, .leading, .trailing, .width, .height, .centerX, .centerY).greaterThanOrEqualTo()
                Anchors(.bottom).greaterThanOrEqualTo(constant: 13.0)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect)
    }
    
    func testAnchorsLessThanOrEqualToUILayoutAnchor() {
        
        activation = root {
            red.anchors {
                Anchors.top.lessThanOrEqualTo(root.topAnchor)
                Anchors.leading.lessThanOrEqualTo(root.leadingAnchor)
                Anchors.trailing.lessThanOrEqualTo(root.trailingAnchor)
                Anchors.bottom.lessThanOrEqualTo(root.bottomAnchor)
                Anchors.width.lessThanOrEqualTo(root.widthAnchor)
                Anchors.height.lessThanOrEqualTo(root.heightAnchor).constant(12.0)
                Anchors.centerX.lessThanOrEqualTo(root.centerXAnchor)
                Anchors.centerY.lessThanOrEqualTo(root.centerYAnchor)
            }
        }.active()
        
        let expect = """
        root {
            red.anchors {
                Anchors(.top, .bottom, .leading, .trailing, .width, .centerX, .centerY).lessThanOrEqualTo()
                Anchors(.height).lessThanOrEqualTo(root, constant: 12.0)
            }
        }
        """.tabbed
        
        XCTAssertEqual(SwiftLayoutPrinter(root).print(), expect)
    }
    
}
