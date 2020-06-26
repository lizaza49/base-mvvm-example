//
//  OfficesOfficesRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol OfficesMapRouterProtocol: OfficeRouterProtocol {
	var officeRouter: OfficeRouterProtocol { get set }
}

///
final class OfficesMapRouter: BaseRouter, OfficesMapRouterProtocol {
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
