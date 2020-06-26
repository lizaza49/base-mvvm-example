//
//  URLRequestConvertible+Conformances.swift
//  BaseMVVMExample
//
//  Created by Admin on 08/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Alamofire

///
extension URL: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self)
    }
}
