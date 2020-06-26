//
//  MapPopupModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 13/04/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import RxSwift

///
class MapPopupModuleConfigurator: NSObject {
	
	/**
	*/
	static func configure(with vc: MapPopupViewController,
						  containerView: UIView,
						  office: Office,
						  displayStyle: OfficiesDisplayStyle,
						  officeRouter: OfficeRouterProtocol,
						  delegate: MapPopupViewDelegate?,
						  loadingStateDelegate: LoadingStateDelegate?) -> MapPopupModuleInputProtocol {
		let router = MapPopupRouter(viewController: vc)
		let viewModel = MapPopupViewModel(router: router, displayStyle: displayStyle, office: office, officeRouter: officeRouter, delegate: delegate, loadingStateDelegate: loadingStateDelegate)
		vc.viewModel = viewModel
		return viewModel
	}
}
