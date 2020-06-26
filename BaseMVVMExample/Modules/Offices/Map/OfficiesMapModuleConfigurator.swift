//
//  OfficiesMapModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 18/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

class OfficiesMapModuleConfigurator {
	
	/**
	*/
    static func configure(with vc: OfficesMapViewController, displayStyle: OfficiesDisplayStyle, officesService: OfficiesServiceProtocol?) {
		let router = OfficesMapRouter(viewController: vc)
		vc.viewModel = OfficesMapViewModel(router: router,
										   displayStyle: displayStyle,
										   officiesService: officesService,
										   locationService: AppDependencyInjection.container.resolve(LocationServiceProtocol.self))
	}
}
