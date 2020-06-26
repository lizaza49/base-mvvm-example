//
//  OfficesOfficesViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import YandexMapKit

///
protocol OfficesMapViewModelProtocol: LoadingStateDelegate, BaseViewModelProtocol {
	init(router: OfficesMapRouterProtocol, displayStyle: OfficiesDisplayStyle, officiesService: OfficiesServiceProtocol?, locationService: LocationServiceProtocol?)
	var displayStyle: OfficiesDisplayStyle { get }
	var router: OfficesMapRouterProtocol { get }
	var locationPosition: Variable<YMKPoint?> { get }
	var officePoints: BehaviorSubject<Set<Office>?> { get }
	var popupInput: MapPopupModuleInputProtocol? { get set }
	var selectedOffice: Variable<Office?> { get }
	var currentFilter: Variable<OfficeServiceType?> { get }
	func onMapViewLoad()
	func loadOfficies()
	func officeIsDisplayedForFilter(office: Office) -> Bool
}

///
final class OfficesMapViewModel: BaseViewModel, OfficesMapViewModelProtocol {

	var displayStyle: OfficiesDisplayStyle
	var router: OfficesMapRouterProtocol

	var selectedOffice: Variable<Office?> = Variable(nil)
	var popupInput: MapPopupModuleInputProtocol? = nil
	
	var officePoints = BehaviorSubject<Set<Office>?>(value: nil)
	var locationPosition = Variable<YMKPoint?>(nil)
	var isLoading: Variable<Bool> = Variable(false)
	var currentFilter = Variable<OfficeServiceType?>(nil)
	
	private var locationService: LocationServiceProtocol?
	private var officiesService: OfficiesServiceProtocol?
	
	required init(router: OfficesMapRouterProtocol,
				  displayStyle: OfficiesDisplayStyle,
				  officiesService: OfficiesServiceProtocol?,
				  locationService: LocationServiceProtocol?) {
		self.router = router
		self.displayStyle = displayStyle
		self.officiesService = officiesService
		self.locationService = locationService
		super.init()
		setupBindings()
	}
	
	required init(router: OfficesMapRouterProtocol) {
		fatalError("You must use init(router: officiesService:) to create a BaseFormViewModel instance")
	}
	
	func onMapViewLoad() {
		locationService?.requestAuthorization()
		officiesService?.searchString.value = nil
		loadOfficies()
	}
	
	func loadOfficies() {
		officiesService?.officies
			.asObservable()
			.bind(onNext: configure)
			.disposed(by: disposeBag)
		
		officiesService?.filter
			.asObservable()
			.bind(to: currentFilter)
			.disposed(by: disposeBag)
	}
	
	func officeIsDisplayedForFilter(office: Office) -> Bool {
		guard let filter = currentFilter.value else { return true }
		return office.services?.compactMap({ $0 == filter }).count ?? 0 > 0
	}
	
	private func setupBindings() {
		locationService?.authorizationStatus
			.asObservable()
			.bind(onNext: { [weak self] (authorized) in
				guard let self = self else { return }
				if authorized {
					self.locationService?.requestCurrentLocation()
				}
			})
			.disposed(by: disposeBag)
		
		locationService?.currentLocation
			.asObservable()
			.bind(onNext: { [weak self] (location) in
				guard let self = self else { return }
				self.locationPosition.value = location?.position
			})
			.disposed(by: disposeBag)
	}
	
	private func configure(officies: [Office]?) {
		guard let officies = officies else { return }
		officePoints.onNext(Set(officies))
	}
}
