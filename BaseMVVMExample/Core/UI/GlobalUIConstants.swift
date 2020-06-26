//
//  GlobalUIConstants.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
struct GlobalUIConstants {
    
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    ///
    struct Logo {
        static let size = CGSize(width: 220, height: 94)
        static let taglineSize = CGSize(width: 220, height: 12.4)
        static let topInsetMultiplier: CGFloat = 0.045
        static let topInset: CGFloat = screenHeight * topInsetMultiplier
    }
}
