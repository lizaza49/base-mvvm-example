//
//  StringConvertible.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol StringConvertible {
    var asString: String { get }
}

///
extension String: StringConvertible {
    var asString: String {
        return self
    }
}
