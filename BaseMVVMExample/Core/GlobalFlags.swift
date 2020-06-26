//
//  GlobalFlags.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
var iOS10: Bool {
    if #available(iOS 11, *) {
        return false
    }
    else {
        return true
    }
}
