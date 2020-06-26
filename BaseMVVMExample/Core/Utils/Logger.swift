//
//  Logger.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Crashlytics
import FirebaseAnalytics

public enum LogContext : NSInteger {
    
    // MARK: Events
    case evns = 1000    // system events
    case evna = 1001    // application events
    
    // MARK: Navigation
    case navt = 2000    // navigation transitions
    case navl = 2001    // deep linking route resolutions
    
    // MARK: Service
    case srvb = 3000    // backend service endpoints / actions
    case srvt = 3001    // third-party services endpoint / actions
    
    // MARK: User
    case uact = 9000    // user actions
    
    // MARK: Unknown
    case uknw = 0       // unknown context
}

extension LogContext : CustomStringConvertible {
    public var description: String {
        switch self {
        case .evns: return "EVNS"
        case .evna: return "EVNA"
        case .navt: return "NAVT"
        case .navl: return "NAVL"
        case .srvb: return "SRVB"
        case .srvt: return "SRVT"
        case .uact: return "UACT"
        case .uknw: return "UKNW"
        }
    }
}

// MARK: Custom console log formatter

class CustomRawLogFormatter : NSObject, DDLogFormatter {
    
    func format(message logMessage: DDLogMessage) -> String? {
        
        // Log level color
        let logColor: String = {
            switch logMessage.flag {
            case DDLogFlag.error: return "31"       // red
            case DDLogFlag.warning: return "33"     // yellow
            case DDLogFlag.info: return "34"        // blue
            case DDLogFlag.verbose: fallthrough     // cyan
            case DDLogFlag.debug: fallthrough       // cyan
            default: return "36"                    // cyan
            }
        }()
        
        // Define context
        var context = LogContext(rawValue: logMessage.context)
        if case .none = context {
            context = LogContext.uknw
        }
        
        return "\u{001b}[\(logColor)m\(context!.description)\u{001b}[0m: \(logMessage.message)"
    }
}

// MARK: Log level description

extension DDLogLevel : CustomStringConvertible {
    public var description: String {
        switch self {
        case .error: return "Error"
        case .warning: return "Warning"
        case .info: return "Info"
        case .verbose: return "Verbose"
        case .debug: return "Debug"
        default: return ""
        }
    }
}

// MARK: Crashlytics logger

class CrashlyticsLogger : DDAbstractLogger {
    override func log(message: DDLogMessage) {
        
        var params = message.tag as? [String: Any] ?? [:]
        
        // Log error to crashlytics as non-fatal issue
        if let error = params["error"] as? Error {
            Crashlytics.sharedInstance().recordError(error)
            params["error"] = nil
        }
        
        let paramsString = params.map { key, value in "\(key): \(value)"}.reduce("") { return "\($0), \($1)" }
        
        var msg = message.message
        if paramsString.count > 0 {
            msg += "(\(paramsString)"
        }
        
        CLSLogv("%@ %@ %@", getVaList([
            message.level.description.uppercased(),
            LogContext(rawValue: message.context)!.description,
            msg]))
    }
}

// Firebase Analytics logger

class FirebaseAnalyticsLogger : DDAbstractLogger {
    override func log(message: DDLogMessage) {
        
        var params: [String: Any] = [
            "level" : message.level.description.lowercased(),
            "context" : LogContext(rawValue: message.context)!.description.lowercased()
        ]
        
        for (k, v) in (message.tag as? [String: Any] ?? [:]) {
            params[k] = v
        }
        
        Analytics.logEvent(message.message, parameters: params)
    }
}

func DDLogDebug(context: LogContext, message: String, params: [String: Any]) {
    DDLogDebug(message, level: .debug, context: context.rawValue, tag: params)
}

func DDLogVerbose(context: LogContext, message: String, params: [String: Any]) {
    DDLogVerbose(message, level: .verbose, context: context.rawValue, tag: params)
}

func DDLogInfo(context: LogContext, message: String, params: [String: Any]) {
    DDLogInfo(message, level: .info, context: context.rawValue, tag: params)
}

func DDLogWarn(context: LogContext, message: String, params: [String: Any]) {
    DDLogWarn(message, level: .warning, context: context.rawValue, tag: params)
}

func DDLogError(context: LogContext, message: String, params: [String: Any], error: Swift.Error?) {
    
    // Optional error goes to params
    var mParams = params
    if let err = error {
        mParams["error"] = err.localizedDescription
    }
    
    DDLogError(message, level: .error, context: context.rawValue, tag: mParams)
}
