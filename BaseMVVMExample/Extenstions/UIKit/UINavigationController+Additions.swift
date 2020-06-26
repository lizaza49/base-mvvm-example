//
//  UINavigationController+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension UINavigationController {
    
    /**
     */
    func dropChildren(in range: Range<Int>) {
        guard range.lowerBound > 0,
            range.upperBound < viewControllers.count
            else { return }
        viewControllers.removeSubrange(range)
    }
}
