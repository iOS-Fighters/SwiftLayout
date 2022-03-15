//
//  ViewPair.swift
//  
//
//  Created by oozoofrog on 2022/02/14.
//

import Foundation

final class ViewInformation: Hashable, CustomDebugStringConvertible {
    
    init(superview: SLView?, view: SLView?) {
        self.superview = superview
        self.view = view
    }
    
    private(set) public weak var superview: SLView?
    private(set) public weak var view: SLView?
    var identifier: String? { view?.slIdentifier }
    
    func addSuperview() {
        guard let view = view else {
            return
        }
        if superview != view.superview {
            superview?.addSubview(view)
        }
    }
    
    func removeFromSuperview() {
        guard superview == view?.superview else { return }
        view?.removeFromSuperview()
    }
    
    var debugDescription: String {
        "\(superview?.tagDescription ?? "nil"):\(view?.tagDescription ?? "nil")"
    }
}

// MARK: - Hashable
extension ViewInformation {
    
    static func == (lhs: ViewInformation, rhs: ViewInformation) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(superview)
        hasher.combine(view)
    }
}

struct ViewInformationSet: Hashable {
    
    let infos: Set<ViewInformation>
    
    init(infos: [ViewInformation] = []) {
        self.infos = Set(infos)
    }
    
    subscript(_ identifier: String) -> SLView? {
        infos.first(where: { $0.identifier == identifier })?.view
    }
}