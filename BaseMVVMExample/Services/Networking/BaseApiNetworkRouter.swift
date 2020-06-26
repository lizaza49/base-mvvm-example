//
//  BaseApiService.swift
//  BaseMVVMExample
//
//  Created by Admin on 13/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Moya

///
protocol BaseApiNetworkRouterProtocol: TargetType {
    var mockJsonFileName: String? { get }
}

///
extension BaseApiNetworkRouterProtocol {
    var baseURL: URL { return Constants.apiUrl }
    var sampleData: Data {
        guard let mockJsonFileName = mockJsonFileName else {
            return Data()
        }
        guard let path = Bundle.main.path(forResource: mockJsonFileName, ofType: "json") else {
            return Data()
        }
        do {
            let url = URL(fileURLWithPath: path)
            return try Data(contentsOf: url)
        }
        catch {
            Log.some("failed to parse mock json")
            return Data()
        }
    }
    var parameters: [String: Any]? {
        return nil
    }

    var headers: [String : String]? {
        var headers = [
            "Authorization": "Basic \(Constants.basicAuthToken)"
        ]
        if let email = User.shared.email,
            let token = KeychainService().token(for: email) {
            headers["Authentication"] = "Bearer \(token)"
            Log.some("Token: \(token)")
        }
        return headers
    }
    
    var mockJsonFileName: String? { return nil }
}
