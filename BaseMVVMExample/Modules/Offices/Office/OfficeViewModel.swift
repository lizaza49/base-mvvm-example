//
//  OfficeOfficeViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 14/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation
import YandexMapKit

///
enum OfficeViewDisplayStyle {
	case popup(displayStyle: OfficiesDisplayStyle)
	case listItem(displayStyle: OfficiesDisplayStyle)
}

///
protocol LoadingStateDelegate: class {
	var isLoading: Variable<Bool> { get }
}

///
protocol OfficeViewModelProtocol: class, MapPopupContainerDimensionsSource {
	var router: OfficeRouterProtocol? { get set }
	var office: Office { get }
	var id: String? { get set }
	var adress: String? { get set }
	var title: String? { get set }
	var workingSchedule: String { get }
	var distance: Int? { get }
	var routeDistance: Variable<String?> { get }
	
	var phones: [OfficePhoneViewModelProtocol]? { get }
	var options: [OfficeKeyValueViewModelProtocol]? { get }
	var displayStyle: OfficeViewDisplayStyle { get }
	var isExpanded: Variable<Bool> { get }
	var isPicked: Variable<Bool> { get }
	var pickSignal: PublishSubject<Void> { get }
	
	func viewDidRequestRouteToOffice()
	func viewDidRequestCall(phone: String)
	func viewDidPickItem()
	func toggleExpansionState()
}

///
class OfficeViewModel: OfficeViewModelProtocol {
	var router: OfficeRouterProtocol?
	var id: String?
	var adress: String?
	var title: String?
	var workingSchedule: String = ""
	var distance: Int?
	var routeDistance: Variable<String?> = Variable(nil)
	var phones: [OfficePhoneViewModelProtocol]?
	var options: [OfficeKeyValueViewModelProtocol]?
	var displayStyle: OfficeViewDisplayStyle
	var isExpanded: Variable<Bool> = Variable(false)
	var isPicked: Variable<Bool>
	var pickSignal = PublishSubject<Void>()
	var contentHeight: MapPopupContentHeight = .zero
	let office: Office
	
	private let currentLocation: YMKLocation?
	private weak var loadingStateDelegate: LoadingStateDelegate?

	/**
	*/
	init(router: OfficeRouterProtocol?, office: Office, displayStyle: OfficeViewDisplayStyle, loadingStateDelegate: LoadingStateDelegate? = nil, currentLocation: YMKLocation?, isPicked: Bool) {
		
		self.router = router
		self.currentLocation = currentLocation
		self.office = office
		self.loadingStateDelegate = loadingStateDelegate
		self.id = office.id
		self.adress = office.address
		self.title = office.title
		self.phones = office.phones?.compactMap { OfficePhoneViewModel(phone: $0)}
		
		self.options = office.options?.compactMap {
			OfficeKeyValueViewModel(key: $0.name, value: $0.value)
		}
		
		self.displayStyle = displayStyle
		self.workingSchedule = office.openingTime?.replacingOccurrences(of: "; ", with: "\n") ?? ""
		self.isPicked = Variable<Bool>(isPicked)
		
		updateDistance()
		
		// Calc content height
		calculateContentHeight()
	}
	
	func updateDistance() {
		if let currentLocation = currentLocation {
			let currentLat = currentLocation.position.latitude
			let currentLon = currentLocation.position.longitude
			
			let currentCLlocation = CLLocation(latitude: currentLat, longitude: currentLon)
			
			let officeCLlocation = CLLocation(latitude: office.lat, longitude: office.lon)
			
			let distanceToOffice = currentCLlocation.distance(from: officeCLlocation)
			
			let distanceInMeters = Int(distanceToOffice)
			self.distance = distanceInMeters
			if distanceInMeters > 0 {
				if distanceInMeters < 1000 {
					routeDistance.value = L10n.Common.Office.Distance.meters(String(distanceInMeters))
				}
				else {
					var distanceKm = Double(distanceInMeters) / 1000.0
					distanceKm = round(distanceKm * 10.0) / 10.0
					routeDistance.value = L10n.Common.Office.Distance.km(String(distanceKm))
				}
			}
		}
	}
	
	func viewDidRequestRouteToOffice() {
		router?.showRoute(toOfficeAt: office.lat, lon: office.lon)
	}
	
	func viewDidRequestCall(phone: String) {
		router?.call(to: phone)
	}
	
	func toggleExpansionState() {
		isExpanded.value = !isExpanded.value
	}
	
	func viewDidPickItem() {
		pickSignal.onNext(())
	}
	
	private func calculateContentHeight() {
		if case let OfficeViewDisplayStyle.popup(displayStyle: dispStyle) = displayStyle, dispStyle == .normal {
			calculateHeightForNormal()
		}
		
		if case let OfficeViewDisplayStyle.listItem(displayStyle: dispStyle) = displayStyle, dispStyle == .normal {
			calculateHeightForNormal()
		}
		
		if case let OfficeViewDisplayStyle.popup(displayStyle: dispStyle) = displayStyle, dispStyle == .picker {
			calculateHeightForPicker()
		}
		
		if case let OfficeViewDisplayStyle.listItem(displayStyle: dispStyle) = displayStyle, dispStyle == .picker {
			calculateHeightForPicker()
		}
	}
	
	private func calculateHeightForNormal() {
		var collapsedHeight = OfficeHeadingView.estimatedHeight(for: self)
		
		let scheduleHeight: CGFloat = OfficeScheduleCollectionViewCell.estimatedSize(item: OfficeScheduleViewModel(schedule: self.workingSchedule), collectionViewSize: CGSize(width: 0, height: UIScreen.main.bounds.width)).height
		
		let phonesHeight: CGFloat = CGFloat(48 * (phones?.count ?? 0))
		
		var optionsHeight: CGFloat = 0.0
		
		if let options = options {
			for option in options {
				let optionHeight = OfficeKeyValueCollectionViewCell.estimatedSize(item: option, collectionViewSize: CGSize(width: 0, height: UIScreen.main.bounds.width)).height + 1.0
				optionsHeight += optionHeight
			}
		}
		
		let expandedHeight: CGFloat = collapsedHeight + phonesHeight + scheduleHeight + optionsHeight
		
		switch displayStyle {
		case .popup:
			collapsedHeight -= 27
			break
		case .listItem:
			break
		}
		
		contentHeight = MapPopupContentHeight(
			collapsed: collapsedHeight,
			expanded: expandedHeight)
	}
	
	private func calculateHeightForPicker() {
		var mainHeight: CGFloat = OfficePickerCollectionViewCell.estimatedSize(item: self, collectionViewSize: CGSize(width: 0, height: UIScreen.main.bounds.width)).height
		
		switch displayStyle {
		case .popup:
			break
		case .listItem:
			mainHeight += 16
			break
		}
		
		contentHeight = MapPopupContentHeight(
			collapsed: mainHeight,
			expanded: mainHeight)
	}
}
