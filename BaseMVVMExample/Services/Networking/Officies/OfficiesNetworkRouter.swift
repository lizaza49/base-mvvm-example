//
//  OfficiesNetworkRouter.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 10/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import Moya

enum OfficiesNetworkRouter {
	case getOfficies
	case getPickerOfficies(policyTypeID: String, regionID: Int, settlementID: String)
}

extension OfficiesNetworkRouter: TargetType, BaseApiNetworkRouterProtocol {
	var path: String {
		switch self {
		case .getOfficies:
			return "/v1/offices/"
		case .getPickerOfficies(let policyTypeID, let regionID, _):
			return "/v1/\(policyTypeID)/\(regionID)/offices/"
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .getOfficies, .getPickerOfficies:
			return .get
		}
	}
	
	var task: Task {
		switch self {
		case .getOfficies:
			return .requestPlain
		case .getPickerOfficies(_, _, let settlementID):
			return Task.requestParameters(parameters: ["settlementID": settlementID], encoding: URLEncoding.default)
		}
	}
	
	var mockJsonFileName: String? {
		switch self {
		case .getOfficies, .getPickerOfficies:
			return "officies"
		}
	}
}
