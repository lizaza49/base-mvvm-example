//
//  OfficiesFilterOptionViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 26/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

enum OfficiesFilterOption: Equatable {
	
	static func == (lhs: OfficiesFilterOption, rhs: OfficiesFilterOption) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	case insurance
	case lossAdjustment
	
	private var identifier: String {
		switch self {
		case .insurance: return "insurance"
		case .lossAdjustment: return "lossAdjustment"
		}
	}
	
	var title: String {
		switch self {
		case .insurance: return L10n.Common.Map.Filter.insurance
		case .lossAdjustment: return L10n.Common.Map.Filter.lossAdjustment
		}
	}
	
	var enumeratedTitle: String {
		switch self {
		default:
			return title
		}
	}
}
