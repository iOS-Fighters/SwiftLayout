import Foundation
import UIKit

public struct ConditionalLayout<True: Layout, False: Layout>: Layout {
    enum Layout {
        case trueLayout(True)
        case falseLayout(False)
    }
    let layout: Layout
    
    public var debugDescription: String {
        "ConditionalLayout<True: \(True.self), False: \(False.self)>"
    }
}

public extension ConditionalLayout {
    func traverse(_ superview: UIView?, continueAfterViewLayout: Bool, traverseHandler handler: TraverseHandler) {
        switch layout {
        case let .trueLayout(layout):
            layout.traverse(superview, continueAfterViewLayout: continueAfterViewLayout, traverseHandler: handler)
        case let .falseLayout(layout):
            layout.traverse(superview, continueAfterViewLayout: continueAfterViewLayout, traverseHandler: handler)
        }
    }
    func traverse(_ superview: UIView?, viewInfoSet: ViewInformationSet, constraintHndler handler: (UIView?, UIView, [Constraint], ViewInformationSet) -> Void) {
        switch layout {
        case let .trueLayout(layout):
            layout.traverse(superview, viewInfoSet: viewInfoSet, constraintHndler: handler)
        case let .falseLayout(layout):
            layout.traverse(superview, viewInfoSet: viewInfoSet, constraintHndler: handler)
        }
    }
}
