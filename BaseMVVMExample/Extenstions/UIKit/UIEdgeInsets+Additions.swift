//
//  UIEdgeInsets+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
enum UIEdgeInset {
    case top, bottom, left, right
}

/**
 */
extension UIEdgeInsets {
    
    /**
     */
    mutating func set(_ inset: UIEdgeInset, value: CGFloat) {
        switch inset {
        case .top:
            self.top = value
            break
        case .bottom:
            self.bottom = value
            break
        case .left:
            self.left = value
            break
        case .right:
            self.right = value
            break
        }
    }
}
