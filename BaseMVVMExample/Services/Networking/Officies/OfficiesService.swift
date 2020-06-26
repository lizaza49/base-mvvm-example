//
//  OfficiesService.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 10/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

protocol OfficiesServiceProtocol {
	var officies: Variable<[Office]?> { get }
	var filter: Variable<OfficeServiceType?> { get }
	var filterOptions: [OfficeServiceType] { get }
	var searchString: Variable<String?> { get }
	var filteredOfficies: [OfficeServiceType: [Office]] { get }
	func requestOfficies()
	func requestOfficiesForPicker(policyTypeID: String, regionID: Int, settlementID: String)
}

final class OfficiesService: NSObject, OfficiesServiceProtocol {
	var filter = Variable<OfficeServiceType?>(nil)
	var officies = Variable<[Office]?>(nil)
	var filteredOfficies: [OfficeServiceType : [Office]] = [:]
	var filterOptions: [OfficeServiceType] = [.insurance, .lossAdjustment]
	var searchString = Variable<String?>(nil)
	
	private lazy var httpClient = HTTPClient()
	private let disposeBag = DisposeBag()
	private var allOfficies: [Office]?
	
	override init() {
		super.init()
		setupBindings()
	}
	
	func requestOfficies() {
		getAllOfficies()
	}
	
	func requestOfficiesForPicker(policyTypeID: String, regionID: Int, settlementID: String) {
		
		getOfficiesForPicker(policyTypeID, regionID, settlementID)
			.takeUntil(rx.deallocated)
			.subscribeOn(ConcurrentMainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				guard let self = self else { return }
				self.officies.value = $0
			}).disposed(by: disposeBag)
	}
	
	private func getAllOfficies() {
		getOfficies()
			.takeUntil(rx.deallocated)
			.subscribeOn(ConcurrentMainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				guard let self = self else { return }
				self.allOfficies = $0
				for filter in self.filterOptions {
					self.filteredOfficies[filter] = self.allOfficies?.filter({
						$0.services?.filter({ $0 == filter}).count ?? 0 > 0
					})
					
				}
				self.officies.value = self.filteredOfficies[.insurance]
				}, onError: { error in
					//add error processing
			}).disposed(by: disposeBag)
	}
	
	private func setupBindings() {
		//getAllOfficies()
		
		filter.asObservable()
			.bind(onNext: { [weak self] (filter) in
				guard let self = self else { return }
				if let filter = filter {
					self.officies.value = self.filteredOfficies[filter]
				} else {
					self.officies.value = self.allOfficies
				}
			}).disposed(by: disposeBag)
		
		searchString.asObservable()
			.observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
			.bind(onNext: { [weak self] (searchString) in
				guard let self = self else { return }
				if let search = searchString, search != "" {
					self.officies.value = self.officies.value?.filter({ $0.title.lowercased().contains(search.lowercased())})
				} else {
					self.officies.value = self.filter.value != nil ? self.filteredOfficies[self.filter.value!] : self.allOfficies
				}
				
		}).disposed(by: disposeBag)
	}
	
	private func getOfficies() -> Observable<[Office]?> {
		return httpClient.request(token: OfficiesNetworkRouter.getOfficies)
	}
	
	private func getOfficiesForPicker(_ policyTypeID: String, _ regionID: Int, _ settlementID: String) -> Observable<[Office]?> {
		return httpClient.request(token: OfficiesNetworkRouter.getPickerOfficies(policyTypeID: policyTypeID, regionID: regionID, settlementID: settlementID))
	}
}
