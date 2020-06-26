//
//  OfficiesWrapperOfficiesWrapperRouter.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
protocol OfficiesWrapperRouterProtocol: OfficeRouterProtocol {
	func showOfficiesFilter(
		in view: UIView,
		options: [OfficiesFilterOption],
		selectedOption: Variable<OfficiesFilterOption?>) -> DismissableViewModelProtocol?
	func dismissFilterView()
}

///
final class OfficiesWrapperRouter: BaseRouter, OfficiesWrapperRouterProtocol {

	private weak var officiesFilterVC: UIViewController?
	
	func showOfficiesFilter(
		in view: UIView,
		options: [OfficiesFilterOption],
		selectedOption: Variable<OfficiesFilterOption?>) -> DismissableViewModelProtocol? {
		
		guard let selectedOptionValue = selectedOption.value else { return nil }
		let vc = OfficiesFiltersViewController()
		let router = OfficiesFiltersRouter(viewController: vc)
		let viewModel = OfficiesFiltersViewModel(router: router,
														filterOptions: options,
														selectedOption: selectedOptionValue)
		
		viewModel.selectedOption
			.bind(to: selectedOption)
			.disposed(by: viewModel.disposeBag)
		
		vc.viewModel = viewModel
		officiesFilterVC = vc
		baseViewController?.add(childVC: vc, to: view)
		return viewModel
	}
	
	func dismissFilterView() {
		officiesFilterVC?.dismiss(animated: true, completion: nil)
	}
}
