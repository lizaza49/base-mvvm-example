//
//  BaseError.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
enum BaseError: Error {
    case undefined
	case message(String)
    case apiError(ApiErrorResponse)
	case parsingError(code: HTTPStatusCode)
    case serverError
    case networkUnreachable
    case requestTimeout
    case invalidInput
}

///
extension BaseError: LocalizedError {
    
    ///
    public var errorDescription: String? {
        switch self {
        case .serverError:
            return L10n.Common.Error.Network.backendError
        case .parsingError:
            return L10n.Common.Error.Network.parsingError
        case .networkUnreachable:
            return L10n.Common.Error.Network.unreachable
        case .requestTimeout:
            return L10n.Common.Error.Network.requestTimeout
        case .message(let message):
            return message
        case .apiError(let error):
            return error.userTitle
        default:
            return L10n.Common.Error.Common.undefined
        }
    }
}
