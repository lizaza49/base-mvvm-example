//
//  MapPopupMapPopupViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 13/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
///
enum MapPopupState: Int, Comparable {
	static func < (lhs: MapPopupState, rhs: MapPopupState) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
	case hidden = 0, collapsed, expanded
	static let ordered: [MapPopupState] = [.hidden, .collapsed, .expanded]
}

///
protocol MapPopupContainerDimensionsSource {
	var contentHeight: MapPopupContentHeight { get }
}

///
struct MapPopupContentHeight {
	var collapsed: CGFloat
	private var _expanded: CGFloat?
	var expanded: CGFloat {
		return _expanded ?? collapsed
	}
	
	static let zero = MapPopupContentHeight(collapsed: 0, expanded: 0)
	
	init(collapsed: CGFloat, expanded: CGFloat?) {
		self.collapsed = collapsed
		self._expanded = expanded
	}
	
	/**
	*/
	func height(for state: MapPopupState) -> CGFloat {
		switch state {
		case .collapsed: return collapsed
		case .expanded: return expanded
		case .hidden: return 0
		}
	}
}

///
enum MapPopupContentType: Equatable {
	case office(Office)
	
	private var office: Office? {
		if case .office(let office) = self { return office }
		return nil
	}
	///
	public static func == (lhs: MapPopupContentType, rhs: MapPopupContentType) -> Bool {
		return lhs.office == rhs.office
	}
}

///
struct MapPopupContainerHeightUpdate {
	var height: CGFloat
	var animated: Bool
	var animationDuration: Double?
	var completionBlock: (() -> Void)?
	
	init(height: CGFloat, animated: Bool = true, animationDuration: Double? = nil, completionBlock: (() -> Void)? = nil) {
		self.height = height
		self.animated = animated
		self.animationDuration = animationDuration
		self.completionBlock = completionBlock
	}
}

///
protocol MapPopupModuleInputProtocol: class {
	func setOffice(_ office: Office)
	func parentDidAddPopup()
}

///
protocol MapPopupModuleOutputProtocol: class {
	func mapPopup(_ mapPopupViewModel: MapPopupViewModel, containerHeightShouldUpdate update: MapPopupContainerHeightUpdate)
}

///
protocol MapPopupViewModelProtocol: BaseViewModelProtocol {
	var router: MapPopupRouterProtocol { get }
	var displayStyle: OfficiesDisplayStyle { get }
	var delegate: MapPopupViewDelegate? { get set }
	var bottomSafeAreaHeight: Variable<CGFloat> { get set }
	
	var contentType: Variable<MapPopupContentType?> { get }
	var contentModel: Variable<Any?> { get }
	var dimensionsSource: Variable<MapPopupContainerDimensionsSource?> { get }
	
	var containerHeightUpdate: Variable<MapPopupContainerHeightUpdate>! { get }
	var state: Variable<MapPopupState> { get }
	
	var topShadowInset: CGFloat { get }
	var currentStateHeight: CGFloat { get }
	
	func containerHeight(for state: MapPopupState) -> CGFloat
	func updateContainer(proposedHeight: CGFloat, animated: Bool, completion: (() -> Void)?)
	
}

///
final class MapPopupViewModel: BaseViewModel, MapPopupViewModelProtocol {
	private weak var loadingStateDelegate: LoadingStateDelegate?
	private lazy var locationService: LocationServiceProtocol? = AppDependencyInjection.container.resolve(LocationServiceProtocol.self)
	
	weak var delegate: MapPopupViewDelegate?
	var router: MapPopupRouterProtocol
	var displayStyle: OfficiesDisplayStyle
	var delegateRouter: OfficeRouterProtocol
	var bottomSafeAreaHeight = Variable<CGFloat>(0)
	
	let contentType: Variable<MapPopupContentType?>
	let contentModel: Variable<Any?>
	var dimensionsSource: Variable<MapPopupContainerDimensionsSource?>
	
	var containerHeightUpdate: Variable<MapPopupContainerHeightUpdate>!
	let state: Variable<MapPopupState> = Variable(.collapsed)
	
	let topShadowInset: CGFloat = 16
	var currentStateHeight: CGFloat {
		return containerHeight(for: state.value)
	}
	
	/**
	*/
	init(router: MapPopupRouterProtocol, displayStyle: OfficiesDisplayStyle, office: Office, officeRouter: OfficeRouterProtocol, delegate: MapPopupViewDelegate?, loadingStateDelegate: LoadingStateDelegate? = nil) {
		
		self.delegate = delegate
		self.router = router
		self.displayStyle = displayStyle
		self.loadingStateDelegate = loadingStateDelegate
		self.delegateRouter = officeRouter
		contentType = Variable(.office(office))
		
		let officeViewModel = OfficeViewModel(router: officeRouter, office: office, displayStyle: .popup(displayStyle: displayStyle), loadingStateDelegate: nil, currentLocation: nil, isPicked: false)
		
		dimensionsSource = Variable(officeViewModel)
		contentModel = Variable(officeViewModel)
		
		super.init()
		
		containerHeightUpdate = Variable(MapPopupContainerHeightUpdate(
			height: containerHeight(for: state.value)))
		didInit()
	}
	
	required init(router: MapPopupRouterProtocol) {
		fatalError("init(router:) has not been implemented")
	}
	
	/**
	*/
	private func didInit() {
		setupObservers()
	}
	
	private func setupObservers() {
		contentType.asObservable()
			.bind(onNext: { [weak self] (contentType) in
				guard let self = self else { return }
				self.configureContent(contentType: contentType)
			})
			.disposed(by: disposeBag)
		
		dimensionsSource.asObservable()
			.map { (source) -> MapPopupContainerHeightUpdate in
				let height = self.adjustedContainerHeight(for: (source?.contentHeight.height(for: self.state.value) ?? self.containerHeightUpdate.value.height))
				return MapPopupContainerHeightUpdate(height: height, animated: true)
		}.bind(to: containerHeightUpdate)
		.disposed(by: disposeBag)
		
		bottomSafeAreaHeight.asObservable()
			.skipRepeats()
			.takeUntil(rx.deallocated)
			.map { _ -> MapPopupContainerHeightUpdate in
				return MapPopupContainerHeightUpdate(
					height: self.containerHeight(for: self.state.value),
					animated: true)
			}.bind(to: containerHeightUpdate)
			.disposed(by: disposeBag)
	}
	
	/**
	*/
	private func configureContent(contentType: MapPopupContentType?) {
		guard let contentType = contentType else {
			contentModel.value = nil
			return
		}
		switch contentType {
		case .office(let office):
			let officeVm = OfficeViewModel(
				router: delegateRouter,
				office: office,
				displayStyle: .popup(displayStyle: displayStyle),
				loadingStateDelegate: loadingStateDelegate, currentLocation: locationService?.currentLocation.value, isPicked: false)
			dimensionsSource.value = officeVm
			contentModel.value = officeVm
		}
	}
	
	func containerHeight(for state: MapPopupState) -> CGFloat {
		return adjustedContainerHeight(for: dimensionsSource.value?.contentHeight.height(for: state) ?? 0)
	}
	
	/**
	*/
	func updateContainer(proposedHeight: CGFloat, animated: Bool, completion: (() -> Void)?) {
		containerHeightUpdate.value = MapPopupContainerHeightUpdate(
			height: adjustedContainerHeight(for: proposedHeight),
			animated: animated,
			completionBlock: completion)
	}
	
	/**
	*/
	private func adjustedContainerHeight(for proposedHeight: CGFloat) -> CGFloat {
		return proposedHeight + bottomSafeAreaHeight.value + topShadowInset
	}
}

extension MapPopupViewModel: MapPopupModuleInputProtocol {
	func setOffice(_ office: Office) {
		contentType.value = .office(office)
	}
	
	func parentDidAddPopup() {
		containerHeightUpdate.value = containerHeightUpdate.value
	}
}
