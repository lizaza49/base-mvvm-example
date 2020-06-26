//
//  OfficesListModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation

///
class OfficiesListModuleConfigurator {
	
	/**
	*/
	static func configure(with vc: OfficiesListViewController, displayStyle: OfficiesDisplayStyle, officesService: OfficiesServiceProtocol?) {
		let router = OfficiesListRouter(viewController: vc)
		vc.viewModel = OfficiesListViewModel(router: router,
											 displayStyle: displayStyle,
                                             officiesService: officesService,
                                             locationService: AppDependencyInjection.container.resolve(LocationServiceProtocol.self))
	}
}
