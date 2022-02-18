//
//  Activator.swift
//  
//
//  Created by aiden_h on 2022/02/16.
//

import Foundation
import UIKit

enum Activator {
    static func active(layout: LayoutImp, options: LayoutOptions = [], building: LayoutBuilding? = nil) -> Deactivation {
        return update(layout: layout, fromDeactivation: Deactivation(building: building), options: options)
    }

    @discardableResult
    static func update(layout: LayoutImp, fromDeactivation deactivation: Deactivation, options: LayoutOptions) -> Deactivation {
        let viewInfos = layout.viewInformations
        let viewInfoSet = ViewInformationSet(infos: viewInfos)
        
        deactivate(deactivation: deactivation, withViewInformationSet: viewInfoSet)
        
        if options.contains(.automaticIdentifierAssignment) {
            updateIdentifiers(fromBuilding: deactivation.building, viewInfoSet: viewInfoSet)
        }
        
        let constrains = layout.viewConstraints(viewInfoSet)
        
        activate(viewInfos: viewInfos, constrains: constrains)
        
        deactivation.viewInfos = viewInfoSet
        deactivation.constraints = ConstraintsSet(constraints: constrains)
        
        if options.contains(.usingAnimation) {
            animate(viewInfos: viewInfos)
        }
        
        return deactivation
    }
}

private extension Activator {
    static func deactivate(deactivation: Deactivation, withViewInformationSet viewInfoSet: ViewInformationSet) {
        deactivation.deactiveConstraints()
        
        for existedView in deactivation.viewInfos.infos where !viewInfoSet.infos.contains(existedView) {
            existedView.removeFromSuperview()
        }
    }
    
    static func activate(viewInfos: [ViewInformation], constrains: [NSLayoutConstraint]) {
        for viewInfo in viewInfos {
            viewInfo.addSuperview()
        }
        
        NSLayoutConstraint.activate(constrains)
    }
    
    static func updateIdentifiers(fromBuilding building: LayoutBuilding?, viewInfoSet: ViewInformationSet) {
        guard let rootobject: AnyObject = building ?? viewInfoSet.rootview else {
            assertionFailure("Could not find root view for LayoutOptions.accessibilityIdentifiers. Please use LayoutBuilding.")
            return
        }
        
        IdentifierUpdater(rootobject).update()
    }
    
    static func animate(viewInfos: [ViewInformation]) {
        guard let root = viewInfos.first(where: { $0.superview == nil })?.view else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            root.layoutIfNeeded()
            viewInfos.forEach { information in
                information.animation()
            }
        }
    }
}
