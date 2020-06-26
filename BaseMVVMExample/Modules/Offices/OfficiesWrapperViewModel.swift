//
//  OfficiesWrapperOfficiesWrapperViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

@objc enum OfficiesWrapperDisplayMode: Int {
	case map = 0, list
}


enum OfficiesDisplayStyle {
	case normal, picker
}

///
protocol OfficiesWrapperViewModelProtocol: BaseViewModelProtocol {
	var router: OfficiesWrapperRouterProtocol { get }
	var displayMode: Variable<OfficiesWrapperDisplayMode> { get }
	var displayStyle: OfficiesDisplayStyle { get }
	var filter: Variable<OfficiesFilterOption?> { get }
	func toggleDisplayMode()
	var filterIsDisplayed: Variable<Bool> { get }
	var filterOptions: [OfficiesFilterOption] { get }
    var pickedOffice: BehaviorSubject<Office?> { get }
	var continueButtonText: Variable<String?> { get }
	var continueButtonEnabled: Variable<Bool> { get }
	func continueButtonDidTap()
    var officiesService: OfficiesServiceProtocol? { get }
    
    var pickOfficeControlEvent: PublishSubject<Office?> { get }
}

///
final class OfficiesWrapperViewModel: BaseViewModel, OfficiesWrapperViewModelProtocol {
	var displayStyle: OfficiesDisplayStyle
	var router: OfficiesWrapperRouterProtocol
	
	var filterIsDisplayed = Variable<Bool>(false)
	var filterOptions: [OfficiesFilterOption] = []
	
	var displayMode: Variable<OfficiesWrapperDisplayMode>
	var filter = Variable<OfficiesFilterOption?>(.insurance)
    var pickedOffice = BehaviorSubject<Office?>(value: nil)
	var continueButtonText = Variable<String?>(L10n.Common.Common.Button.pick)
	var continueButtonEnabled = Variable<Bool>(false)
	
	let officiesService: OfficiesServiceProtocol? = AppDependencyInjection.container.resolve(OfficiesServiceProtocol.self)
	private let policyTypeID: String?
	private let regionID: Int?
	private let settlementID: String?
    
    internal let pickOfficeControlEvent: PublishSubject<Office?> = PublishSubject()
	
	required init(router: OfficiesWrapperRouterProtocol,
				  displayStyle: OfficiesDisplayStyle,
				  policyTypeID: String? = nil,
				  regionID: Int? = nil,
				  settlementID: String? = nil) {
		self.router = router
		displayMode = Variable<OfficiesWrapperDisplayMode>(.map)
		self.displayStyle = displayStyle
		self.policyTypeID = policyTypeID
		self.regionID = regionID
		self.settlementID = settlementID
		super.init()
		mapFilterOptions()
		if displayStyle == .normal {
			officiesService?.requestOfficies()
		}
		if displayStyle == .picker {
			if let policyTypeID = policyTypeID,
				let regionID = regionID,
				let settlementID = settlementID {
				officiesService?.requestOfficiesForPicker(policyTypeID: policyTypeID, regionID: regionID, settlementID: settlementID)
			}
		}
		setupBindings()
	}
	
	func toggleDisplayMode() {
		displayMode.value = displayMode.value == .map ? .list : .map
	}
	
	func continueButtonDidTap() {
        pickOfficeControlEvent.onNext((try? pickedOffice.value()) ?? nil)
	}
	
	private func setupBindings() {
		filter.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: { [weak self] (filter) in
				guard let self = self,
						let filter = filter else { return }
				switch filter {
				case .insurance:
					self.officiesService?.filter.value = .insurance
				case .lossAdjustment:
					self.officiesService?.filter.value = .lossAdjustment
				}
			})
			.disposed(by: disposeBag)
		
		pickedOffice.asObservable()
			.map { $0 != nil }
			.bind(to: continueButtonEnabled)
			.disposed(by: disposeBag)
	}
	
	private func mapFilterOptions() {
		filterOptions = []
		if let filtersList = officiesService?.filterOptions {
			filterOptions = filtersList.map { filter -> OfficiesFilterOption in
				switch filter {
				case .insurance:
					return OfficiesFilterOption.insurance
				case .lossAdjustment:
					return OfficiesFilterOption.lossAdjustment
				}
			}
		}
	}
	
}
