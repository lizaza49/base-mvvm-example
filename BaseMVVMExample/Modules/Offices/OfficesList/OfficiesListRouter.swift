//
//  OfficiesListOfficiesListRouter.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

///
protocol OfficiesListRouterProtocol: OfficeRouterProtocol {
	var officeRouter: OfficeRouterProtocol { get set }
}

///
class OfficiesListRouter: BaseRouter, OfficiesListRouterProtocol {
	private var _officeRouter: OfficeRouterProtocol?
	var officeRouter: OfficeRouterProtocol {
		get { return _officeRouter ?? self }
		set { _officeRouter = newValue }
	}
	
	init(sourceViewController: UIViewController, officeRouter: OfficeRouterProtocol?) {
		super.init(viewController: sourceViewController)
		self._officeRouter = officeRouter
	}
	
	required init(viewController: UIViewController) {
		super.init(viewController: viewController)
	}
}
