//
//  LoggerService.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

/**
 */
struct Log {
    /**
     */
    static func some(_ message: Any, shouldStoreLog: Bool = false) {
        LoggerService.shared.log(message)
    }
}

///
protocol LoggerServiceProtocol {
    func log(_ message: Any)
    func log(_ error: Error)
}

///
final class LoggerService: LoggerServiceProtocol {
    
    ///
    static let shared = LoggerService()
    
    /**
     */
    private init() {}
    
    /**
     */
    func log(_ message: Any) {
        performLogging {
            print(message)
        }
    }

    /**
     */
    func log(_ error: Error) {
        performLogging {
            print(error)
        }
    }
    
    /**
     */
    private func performLogging(action: () -> Void) {
        #if DEBUG
        action()
        #endif
    }
}
