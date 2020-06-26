//
//  OfficiesFiltersOfficiesFiltersViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 26/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol OfficiesFiltersViewModelProtocol: DismissableViewModelProtocol, BaseViewModelProtocol {
	var router: OfficiesFiltersRouterProtocol { get }
	var filterOptions: [OfficiesFilterOption] { get }
	var selectedOption: BehaviorSubject<OfficiesFilterOption> { get }
	var selectedOptionIndex: Int? { get }
    
}

///
final class OfficiesFiltersViewModel: BaseViewModel, OfficiesFiltersViewModelProtocol {
	var router: OfficiesFiltersRouterProtocol

	let filterOptions: [OfficiesFilterOption]
	let selectedOption: BehaviorSubject<OfficiesFilterOption>
	var selectedOptionIndex: Int? {
		return (try? filterOptions.firstIndex(of: selectedOption.value())) ?? nil
	}
	let viewWillDismiss = PublishSubject<Void>()
	
	init(router: OfficiesFiltersRouterProtocol,
		 filterOptions: [OfficiesFilterOption],
		 selectedOption: OfficiesFilterOption) {
		self.router = router
		self.filterOptions = filterOptions
		self.selectedOption = BehaviorSubject(value: selectedOption)
		super.init()
	}
	
	required init(router: OfficiesFiltersRouterProtocol) {
		fatalError("init(router:) has not been implemented")
	}
}
