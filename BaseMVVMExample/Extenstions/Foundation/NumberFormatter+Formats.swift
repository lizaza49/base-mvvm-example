//
//  NumberFormatter+Formats.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
extension NumberFormatter {
   
    ///
    static let fileSize: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
