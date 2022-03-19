//
//  UILayoutGuide+Description.swift
//  
//
//  Created by oozoofrog on 2022/03/14.
//

import UIKit

extension UILayoutGuide {
    var propertyDescription: String? {
        guard let view = owningView else { return nil }
        let description = view.tagDescription
        switch identifier {
        case "UIViewLayoutMarginsGuide":
            return description.appending(".layoutMarginsGuide")
        case "UIViewSafeAreaLayoutGuide":
            return description.appending(".safeAreaLayoutGuide")
        case "UIViewKeyboardLayoutGuide":
            return description.appending(".keyboardLayoutGuide")
        case "UIViewReadableContentGuide":
            return description.appending(".readableContentGuide")
        default:
            return description.appending(":\(identifier)")
        }
    }
}
