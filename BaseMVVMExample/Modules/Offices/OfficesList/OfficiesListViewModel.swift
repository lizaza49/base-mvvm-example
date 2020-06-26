//
//  OfficiesListOfficiesListViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

enum OfficiesListSectionType: Int {
	case main = 0
	
	var title: String {
		switch self {
		case .main: return ""
		}
	}
	
	static var all: [OfficiesListSectionType] {
		return [.main]
	}
}

///
enum OfficiesListUpdate {
	case append(officies: [OfficeViewModelProtocol], section: OfficiesListSectionType)
	case insert(officies: [OfficeViewModelProtocol], section: OfficiesListSectionType, row: Int)
	case move(from: OfficiesListOfficePointer, to: OfficiesListOfficePointer)
	case clear(section: OfficiesListSectionType)
}

///
struct OfficiesListItemReload {
	var section: OfficiesListSectionType
	var itemIndex: Int
}

///
class OfficiesListOfficePointer {
	var section: OfficiesListSectionType
	var index: Int
	var officeViewModel: OfficeViewModelProtocol
	
	init(viewModel: OfficeViewModelProtocol, section: OfficiesListSectionType, index: Int) {
		self.officeViewModel = viewModel
		self.section = section
		self.index = index
	}
}

///
protocol OfficiesListViewModelProtocol: LoadingStateDelegate, BaseViewModelProtocol {
	init(router: OfficiesListRouterProtocol, displayStyle: OfficiesDisplayStyle, officiesService: OfficiesServiceProtocol?, locationService: LocationServiceProtocol?)
	var displayStyle: OfficiesDisplayStyle { get }
	var router: OfficiesListRouterProtocol { get }
	var officies: [OfficiesListSectionType: [OfficeViewModelProtocol]] { get }
	var updatesSignal: Variable<[OfficiesListUpdate]> { get }
	var itemReloadSignal: Variable<OfficiesListItemReload?> { get }
	var totalOfficiesCount: Int { get }
	var searchString: Variable<String?> { get }
	var pickedItem: Variable<OfficeViewModelProtocol?> { get }
	func onViewDidLoad()
}

///
final class OfficiesListViewModel: BaseViewModel, OfficiesListViewModelProtocol {
	
	var displayStyle: OfficiesDisplayStyle
	var router: OfficiesListRouterProtocol
	
	private var locationService: LocationServiceProtocol?
	private var officiesService: OfficiesServiceProtocol?
	
	var officies: [OfficiesListSectionType: [OfficeViewModelProtocol]] = [:]
	
	let updatesSignal = Variable<[OfficiesListUpdate]>([])
	let itemReloadSignal = Variable<OfficiesListItemReload?>(nil)
	let isLoading = Variable<Bool>(false)
	var searchString = Variable<String?>(nil)
	var pickedItem = Variable<OfficeViewModelProtocol?>(nil)
	
	var totalOfficiesCount: Int {
		return officies.reduce(0, { $0 + $1.value.count })
	}
	
	required init(router: OfficiesListRouterProtocol,
				  displayStyle: OfficiesDisplayStyle,
				  officiesService: OfficiesServiceProtocol?,
				  locationService: LocationServiceProtocol?) {
		self.router = router
		self.displayStyle = displayStyle
		self.officiesService = officiesService
		self.locationService = locationService
		super.init()
	}
	
	required init(router: OfficiesListRouterProtocol) {
		fatalError("You must use init(router: officiesService:) to create a BaseFormViewModel instance")
	}
	
	func onViewDidLoad() {
		setupObservers()
	}
	
	/**
	*/
	private func setupObservers() {
		officiesService?.officies
			.asObservable()
			.bind(onNext: configureWithReload)
			.disposed(by: disposeBag)
		
		searchString.asObservable()
			.bind(onNext: { [weak self] (searchString) in
				self?.officiesService?.searchString.value = searchString
			})
			.disposed(by: disposeBag)
	}
	
	/**
	*/
	private func configure(with officies: [Office]?) {
		guard let officies = officies else { return }
		configurePage(with: officies)
	}
	
	/**
	*/
	private func configureWithReload(with officies: [Office]?) {
		guard let officies = officies else { return }
		notifyView(of: [.clear(section: .main)])
		configurePage(with: officies)
	}
	
	private func configurePage(with newOfficies: [Office]) {
		let officiesSet = Set(newOfficies)
		
		let updatesDict: [OfficiesListSectionType: [Office]] = [
			.main: Array(officiesSet)
		]
		var updatesToNotify: [OfficiesListUpdate?] = []
		for (section, newOfficies) in updatesDict {
			let officeViewModels = newOfficies.map(makeOfficeViewModel).sorted(by: { first, second in
				if let firstDist = first.distance,
					let secondDist = second.distance {
					return firstDist < secondDist
				}
				return true
			})
			guard !officeViewModels.isEmpty else { continue }
			
			updatesToNotify.append(append(officeViewModels: officeViewModels, to: section))
		}
		notifyView(of: updatesToNotify.compactMap { $0 })
	}
	
	/**
	*/
	private func makeOfficeViewModel(with office: Office) -> OfficeViewModelProtocol {
		let vm = OfficeViewModel(router: router.officeRouter,
								 office: office,
								 displayStyle: .listItem(displayStyle: displayStyle),
								 loadingStateDelegate: self, currentLocation: locationService?.currentLocation.value, isPicked: pickedItem.value?.id == office.id)
		
		vm.isExpanded.asObservable()
			.skipRepeats()
			.map { _ -> OfficiesListItemReload? in
				if let OfficiesListOfficePointer = self.locateOffice(by: vm.id) {
					return OfficiesListItemReload(section: OfficiesListOfficePointer.section, itemIndex: OfficiesListOfficePointer.index)
				}
				return nil
		}.bind(to: itemReloadSignal)
		.disposed(by: disposeBag)
		
		if displayStyle == .picker {
			
			vm.pickSignal
				.bind(onNext: {
					self.pickedItem.value?.isPicked.value = false
					self.pickedItem.value = vm
					vm.isPicked.value = true
				})
				.disposed(by: disposeBag)
		}
		
		return vm
	}
	
	/**
	*/
	@discardableResult
	private func append(officeViewModels: [OfficeViewModelProtocol], to section: OfficiesListSectionType) -> OfficiesListUpdate? {
		return insert(officeViewModels: officeViewModels, to: section, at: officies[section]?.count ?? 0)
	}
	
	/**
	*/
	@discardableResult
	private func insert(officeViewModels: [OfficeViewModelProtocol], to section: OfficiesListSectionType, at index: Int) -> OfficiesListUpdate? {
		guard !officeViewModels.isEmpty else { return nil }
		if officies[section] == nil {
			officies[section] = officeViewModels
		}
		else {
			let localOfficies = officies
			officies[section]?.insert(contentsOf: officeViewModels, at: min(localOfficies[section]!.count, index))
		}
		return .append(officies: officeViewModels, section: section)
	}
	
	/**
	*/
	@discardableResult
	private func move(office pointer: OfficiesListOfficePointer, to section: OfficiesListSectionType) -> OfficiesListUpdate? {
		defer {
			officies[pointer.section]?.remove(at: pointer.index)
		}
		guard let targetOfficeDistance = pointer.officeViewModel.distance else {
			append(officeViewModels: [ pointer.officeViewModel ], to: section)
			return .move(from: pointer,
						 to: OfficiesListOfficePointer(viewModel: pointer.officeViewModel,
													   section: section,
													   index: officies[section]?.count ?? 0))
		}
		var targetInsertionIndex: Int!
		for (offset, office) in (officies[section] ?? []).enumerated() {
			if office.distance == nil || office.distance! > targetOfficeDistance {
				targetInsertionIndex = offset
				break
			}
			else if offset == ((officies[section]?.count ?? 0) - 1) {
				targetInsertionIndex = offset + 1
				break
			}
		}
		targetInsertionIndex = targetInsertionIndex ?? 0
		insert(officeViewModels: [ pointer.officeViewModel ], to: section, at: targetInsertionIndex)
		return .move(from: pointer,
					 to: OfficiesListOfficePointer(viewModel: pointer.officeViewModel,
												   section: section,
												   index: targetInsertionIndex))
	}
	
	/**
	*/
	private func notifyView(of updates: [OfficiesListUpdate]) {
		updatesSignal.value = updates
	}
	
	/**
	*/
	private func locateOffice(by id: String?) -> OfficiesListOfficePointer? {
		guard let id = id else { return nil }
		for (section, officeViewModels) in self.officies {
			if let item = officeViewModels.enumerated().first(where: { $0.element.id == id }) {
				return OfficiesListOfficePointer(viewModel: item.element, section: section, index: item.offset)
			}
		}
		return nil
	}
	
	/**
	*/
	private func defineTargetSection(for officeViewModel: OfficeViewModelProtocol, gonnaBecomeFavourite: Bool) -> OfficiesListSectionType {
		return .main
	}
	
}
