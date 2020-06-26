//
//  Variable+Encodable.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
extension Variable: Codable where Element: Codable {
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
    public convenience init(from decoder: Decoder) throws {
        let element = try Element.init(from: decoder)
        self.init(element)
    }
}
