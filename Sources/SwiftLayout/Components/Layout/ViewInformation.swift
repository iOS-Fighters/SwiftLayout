//
//  ViewPair.swift
//  
//
//  Created by oozoofrog on 2022/02/14.
//

import Foundation
import UIKit

public final class ViewInformation: Hashable {
    
    public static func == (lhs: ViewInformation, rhs: ViewInformation) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public init(superview: UIView?, view: UIView?) {
        self.superview = superview
        self.view = view
    }
    
    private(set) public weak var superview: UIView?
    private(set) public weak var view: UIView?
    public var identifier: String? { view?.accessibilityIdentifier }
    
    
    var capturedFrame: CGRect = .zero
    var isNewlyAdded: Bool = false
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(superview)
        hasher.combine(view)
        hasher.combine(identifier)
    }
    
    func addSuperview() {
        guard let view = view else {
            return
        }
        if superview == view.superview {
            isNewlyAdded = false
        } else {
            superview?.addSubview(view)
            isNewlyAdded = true
        }
    }
    
    func removeFromSuperview() {
        guard superview == view?.superview else { return }
        view?.removeFromSuperview()
    }
    
    func updatingSuperview(_ superview: UIView?) -> Self {
        .init(superview: superview, view: view)
    }
    
    func captureCurrentFrame() {
        capturedFrame = view?.frame ?? .zero
    }
    
    func layoufIfPossible() {
        guard let view = view else { return }
        guard superview != nil && capturedFrame != .zero && !isNewlyAdded else { return }
        view.layoutIfNeeded()
    }
}

extension ViewInformation {
    
    final class AnimationHandler {
        internal init(_ view: UIView? = nil, handler: @escaping AnimationHandler.Handler) {
            self.view = view
            self.handler = handler
        }
        
        typealias Handler = (UIView) -> Void
        weak var view: UIView?
        let handler: Handler
        
        func animation() {
            guard let view = view else {
                return
            }
            handler(view)
        }
    }
}

public struct ViewInformationSet: Hashable {
    
    let infos: Set<ViewInformation>
    var rootview: UIView? { infos.first(where: { $0.superview == nil })?.view }
    
    init(infos: [ViewInformation] = []) {
        self.infos = Set(infos)
    }
    
    subscript(_ identifier: String) -> UIView? {
        infos.first(where: { $0.identifier == identifier })?.view
    }
}
