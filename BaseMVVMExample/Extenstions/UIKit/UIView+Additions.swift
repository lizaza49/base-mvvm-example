//
//  UIView+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 26/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension UIView {
    
    ///
    var mostParentView: UIView {
        return superview?.mostParentView ?? self
    }
}
