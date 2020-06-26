//
//  KeychainService.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import KeychainAccess

///
protocol KeychainServiceProtocol {
    func saveToken(_ token: String, for email: String)
    func token(for email: String) -> String?
}

///
class KeychainService: KeychainServiceProtocol {
    
    ///
    private lazy var keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    /**
     */
    func saveToken(_ token: String, for email: String) {
        do { try keychain.set(token, key: email) }
        catch {
            DDLogError(context: .evna, message: "runtime_error", params: [ "file" : #file, "function" : #function ], error: nil)
        }
    }
    
    /**
     */
    func token(for email: String) -> String? {
        do { return try keychain.getString(email) }
        catch {
            DDLogError(context: .evna, message: "runtime_error", params: [ "file" : #file, "function" : #function ], error: nil)
            return nil
        }
    }
}
