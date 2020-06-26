//
//  OfficiesWrapperModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 02/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
class OfficiesWrapperModuleConfigurator {
	
	/**
	*/
	static func configure(with vc: OfficiesWrapperViewController,
						  displayStyle: OfficiesDisplayStyle,
						  policyTypeID: String? = nil,
						  regionID: Int? = nil,
						  settlementID: String? = nil) {
		let router = OfficiesWrapperRouter(viewController: vc)
		vc.viewModel = OfficiesWrapperViewModel(router: router,
												displayStyle: displayStyle,
												policyTypeID: policyTypeID,
												regionID: regionID,
												settlementID: settlementID)
	}
}
