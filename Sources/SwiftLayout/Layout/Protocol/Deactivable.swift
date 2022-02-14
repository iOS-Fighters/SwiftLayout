//
//  File.swift
//  
//
//  Created by aiden_h on 2022/02/10.
//

import Foundation
import UIKit

public protocol Deactivable {
    func deactive()
    func viewForIdentifier(_ identifier: String) -> UIView?
}
