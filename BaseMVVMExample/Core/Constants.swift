//
//  Constants.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
struct Constants {
    private static let baseUrl = URL(string: "base url string here")!
    private static let apiVersion = "v1"
    static let apiUrl = baseUrl.appendingPathComponent("rest/\(apiVersion)")

    private static let basicAuthLogin = "login"
    private static let basicAuthPassword = "password"
    static let basicAuthToken = "\(basicAuthLogin):\(basicAuthPassword)".data(using: .utf8)!.base64EncodedString()
    
    static let phoneInputMask = "{+7} [000] [000]-[00]-[00]"
    
    struct WebView {
        static let localHeaders: [String: String] = [
            "Client": "EMP"
        ]
    }
}
