import UIKit

@resultBuilder
public struct LayoutBuilder {
    
    public static func buildExpression<L: Layout>(_ layout: L) -> L {
        layout
    }
    
    public static func buildExpression<L: Layout>(_ layout: L?) -> OptionalLayout<L> {
        OptionalLayout(layout: layout)
    }
    
    public static func buildExpression<V: UIView>(_ uiView: V) -> ViewLayout<V> {
        ViewLayout(uiView)
    }
    
    public static func buildExpression<V: UIView>(_ uiView: V?) -> OptionalLayout<ViewLayout<V>> {
        var viewLayout: ViewLayout<V>?
        if let view = uiView {
            viewLayout = ViewLayout(view)
        }
        
        return OptionalLayout(layout: viewLayout)
    }
}

extension LayoutBuilder {
    
    public static func buildBlock<L>(_ layout: L) -> L {
        layout
    }
    
    public static func buildBlock<each L: Layout>(_ l: repeat each L) -> some Layout {
        return TupleLayout(layout: (repeat each L).self)
    }
    
    public static func buildArray<L: Layout>(_ components: [L]) -> ArrayLayout<L> {
        ArrayLayout<L>(layouts: components)
    }
    
    public static func buildOptional<L: Layout>(_ component: L?) -> OptionalLayout<L> {
        OptionalLayout(layout: component)
    }
    
    public static func buildIf<L: Layout>(_ component: L?) -> OptionalLayout<L> {
        OptionalLayout(layout: component)
    }
    
    public static func buildEither<True: Layout, False: Layout>(first component: True) -> ConditionalLayout<True, False> {
        ConditionalLayout<True, False>(layout: .trueLayout(component))
    }
    
    public static func buildEither<True: Layout, False: Layout>(second component: False) -> ConditionalLayout<True, False> {
        ConditionalLayout<True, False>(layout: .falseLayout(component))
    }
    
    public static func buildLimitedAvailability<L: Layout>(_ component: L) -> AnyLayout {
        AnyLayout(component)
    }
}

struct TupleLayout<L>: Layout {
    let layout: L
    
    var sublayouts: [any Layout] {
        let mirror = Mirror(reflecting: self.layout)
        var layouts: [any Layout] = []
        for child in mirror.children {
            guard let layout = child.value as? Layout else {
                continue
            }
            layouts.append(layout)
        }
        return layouts
    }
}
