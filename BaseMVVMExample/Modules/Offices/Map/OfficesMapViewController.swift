//
//  OfficesViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import YandexMapKit
import ClusterKit
import SnapKit
import RxSwift

///
final class OfficesMapViewController: BaseViewController, YMKMapViewDataSource, YMKMapLoadedListener, YMKMapCameraListener, YMKMapObjectTapListener, YMKMapObjectDragListener {
	
	
	var viewModel: OfficesMapViewModelProtocol!
	private lazy var mapView = YMKMapView(frame: view.bounds)
	private var map: YMKMap {
		return mapView.mapWindow.map
	}
	private var isMapLoaded = false
	private let myLocationButton = UIButton()
	private let popupContainerView = UIView()
	
	private let defaultPopupContainerViewHeight: CGFloat = 208
	private let pinStyle = YMKIconStyle(anchor: NSValue(cgPoint: CGPoint(x: 0.5, y: 1)), rotationType: nil, zIndex: nil, flat: nil, visible: nil, scale: nil, tappableArea: nil)
	private let modalPopupVCAccessibilityLabel = "modal_popup_vc"
	private let defaultZoomLevel: Float = 13
	
	// MARK: Life cycle
	
	/**
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupBindings()
		viewModel.onMapViewLoad()
	}
	
	// MARK: Setup
	
	/**
	*/
	private func setupViews() {
		setupMap()
		
		view.addSubview(mapView)
		mapView.snp.makeConstraints({ (make) in
			make.bottom.equalToSuperview()
			make.top.equalToSuperview()
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
		})
		
		myLocationButton.addTarget(self, action: #selector(myLocationButtonTap), for: .touchUpInside)
		myLocationButton.setImage(Asset.Map.geolocation.image, for: .normal)
		view.addSubview(myLocationButton)
		myLocationButton.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(11)
			make.bottom.equalTo(view.snp.bottomMargin).inset(11)
			make.width.height.equalTo(58)
		}
		
		view.addSubview(popupContainerView)
		popupContainerView.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(view.snp.bottom)
			make.height.equalTo(defaultPopupContainerViewHeight)
		}
	}
	
	private func setupMap() {
		mapView.dataSource = self
		let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
		algorithm.cellSize = 200
		mapView.clusterManager.algorithm = algorithm
		mapView.clusterManager.marginFactor = 1
		view.addSubview(mapView)
		mapView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		map.userLocationLayer.isEnabled = true
		map.setMapLoadedListenerWith(self)
		map.addCameraListener(with: self)
		map.isRotateGesturesEnabled = false
		map.logo.setAlignmentWith(YMKLogoAlignment(horizontalAlignment: .right, verticalAlignment: .top))
		
		if let selectedOffice = viewModel.selectedOffice.value {
			map.move(with:
				YMKCameraPosition(target: YMKPoint(latitude: selectedOffice.lat, longitude: selectedOffice.lon),
								  zoom: defaultZoomLevel, azimuth: 0, tilt: 0))
		}
	}
	
	private func setupBindings() {
		viewModel.locationPosition
			.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: { [weak self] (position) in
				guard let self = self,
					let position = position else { return }
				self.updateCameraPosition(position)
			})
			.disposed(by: viewModel.disposeBag)
		
		viewModel.officePoints
			.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: { [weak self] (officies) in
				guard let self = self,
					let officies = officies else { return }
				self.updatePins(for: officies)
			})
			.disposed(by: viewModel.disposeBag)
	}
	
	private func updateCameraPosition(_ position: YMKPoint) {
		mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: position, zoom: 13, azimuth: 0, tilt: 0), animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3), cameraCallback: nil)
	}
	
	private func showModalOfficeInfo(_ office: Office) {
		if let popupInput = viewModel.popupInput {
			viewModel.selectedOffice.value = office
			popupInput.setOffice(office)
			return
		}
		let vc = MapPopupViewController()
		
		vc.accessibilityLabel = modalPopupVCAccessibilityLabel
		viewModel.selectedOffice.value = office
		
		viewModel.popupInput = MapPopupModuleConfigurator.configure(
			with: vc,
			containerView: popupContainerView,
			office: office,
			displayStyle: viewModel.displayStyle,
			officeRouter: viewModel.router.officeRouter,
			delegate: self,
			loadingStateDelegate: viewModel)
		add(childVC: vc, to: popupContainerView)
		viewModel.popupInput?.parentDidAddPopup()
	}
	
	private func dismissCurrentOffice(animated: Bool = true) {
		let completionBlock = {
			if let modalPopupVC = self.childViewControllers.first(where: { $0.accessibilityLabel == self.modalPopupVCAccessibilityLabel }) {
				self.remove(childVC: modalPopupVC)
			}
			self.viewModel.popupInput = nil
			self.viewModel.selectedOffice.value = nil
		}
		if let office = viewModel.selectedOffice.value {
			deselectOfficePin(office: office)
		}
		if animated {
			UIView.animate(withDuration: 0.3, animations: {
				self.popupContainerView.transform = .identity
			}, completion: { _ in
				completionBlock()
			})
		}
		else {
			popupContainerView.transform = .identity
			completionBlock()
		}
	}
	
	private func updatePins(for offices: Set<Office>) {
		let lookupManager = MapObjectLookupManager(userDataSet: offices, strategy: .placemark(negateResults: false))
		lookupManager.traverse(objects: map.mapObjects) { [weak self] (object) in
			guard
				let self = self,
				let office = object.userData as? Office
				else { return }
			
			let isDisplayed = self.viewModel.officeIsDisplayedForFilter(office: office)
			let isSelected = self.viewModel.selectedOffice.value == office
			
			if !isDisplayed {
				self.removePins(of: Set([office]))
				if self.viewModel.selectedOffice.value == office {
					self.dismissCurrentOffice()
				}
				return
			}
			
			(object as? YMKPlacemarkMapObject)?.setIconWith(
				MapOfficeAnnotation.pinAsset(isSelected: isSelected).image,
				style: self.pinStyle)
		}
		let displayedOfficePinsSet = Set(mapView.clusterManager.annotations.compactMap { $0 as? MapOfficeAnnotation }.map { $0.office })
		let officesWithAbsentPins = offices.subtracting(displayedOfficePinsSet)
		updateAnnotations(newOffices: officesWithAbsentPins)
	}
	
	private func updateAnnotations(newOffices: Set<Office> = Set()) {
		let annotations = newOffices.map { MapOfficeAnnotation(office: $0) }
		mapView.clusterManager.addAnnotations(annotations)
		mapView.clusterManager.updateClustersIfNeeded()
	}
	
	/**
	*/
	private func selectOfficePin(office: Office) {
		let lookupManager = MapObjectLookupManager(userData: office, strategy: .placemark(negateResults: false))
		lookupManager.traverse(objects: map.mapObjects) { [weak self] (object) in
			self?.select(officeMapObject: object)
		}
	}
	
	/**
	*/
	private func deselectOfficePin(office: Office) {
		let lookupManager = MapObjectLookupManager(userData: office, strategy: .placemark(negateResults: false))
		lookupManager.traverse(objects: map.mapObjects) { [weak self] (object) in
			self?.deselect(officeMapObject: object)
		}
	}
	
	/**
	*/
	private func select(officeMapObject: YMKMapObject) {
		(officeMapObject as? YMKPlacemarkMapObject)?.setIconWith(
			MapOfficeAnnotation.pinAsset(isSelected: true).image,
			style: pinStyle)
	}
	
	/**
	*/
	private func deselect(officeMapObject: YMKMapObject) {
		(officeMapObject as? YMKPlacemarkMapObject)?.setIconWith(
			MapOfficeAnnotation.pinAsset(isSelected: false).image,
			style: pinStyle)
	}
	
	private func removePins(of offices: Set<Office>) {
		let correspondingAnnotations = mapView.clusterManager.annotations
			.compactMap { $0 as? MapOfficeAnnotation }
			.filter { offices.contains($0.office) }
		mapView.clusterManager.removeAnnotations(correspondingAnnotations)
	}
	
	// MARK: Map
	
	/**
	*/
	
	func mapView(_ mapView: YMKMapView, placemarkFor cluster: CKCluster) -> YMKPlacemarkMapObject {
		let point = YMKPoint(latitude: cluster.coordinate.latitude,
							 longitude: cluster.coordinate.longitude)
		let mapObjects = mapView.mapWindow.map.mapObjects
		var placemark: YMKPlacemarkMapObject!
		if cluster.count > 1 {
			let clusterPinViewModel = MapOfficiesPinClusterViewModel(count: cluster.count)
			let clusterPinView = MapOfficiesClusterPinView(viewModel: clusterPinViewModel)
			if let image = clusterPinView.snapshot() {
				placemark = mapObjects.addPlacemark(with: point, image: image)
			}
			else {
				placemark = mapObjects.addEmptyPlacemark(with: point)
			}
			placemark.userData = cluster.count
		}
		else if let annotation = cluster.firstAnnotation as? MapOfficeAnnotation {
			let office = annotation.office
			let officeIsSelected = viewModel.selectedOffice.value == office
			
			placemark = mapObjects.addPlacemark(
				with: point,
				image: MapOfficeAnnotation.pinAsset(isSelected: officeIsSelected).image,
				style: pinStyle)
			placemark.userData = office
		}
		else {
			// Impossible case
			placemark = mapObjects.addPlacemark(with: point)
		}
		placemark.addTapListener(with: self)
		return placemark
	}
	
	func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateSource: YMKCameraUpdateSource, finished: Bool) {
		guard isMapLoaded, finished else {
			return
		}
		
		mapView.clusterManager.updateClustersIfNeeded()
	}
	
	func onMapLoaded(with statistics: YMKMapLoadStatistics) {
		isMapLoaded = true
	}
	
	func onMapObjectDragStart(with mapObject: YMKMapObject) {
		//
	}
	
	func onMapObjectDrag(with mapObject: YMKMapObject, point: YMKPoint) {
		//
	}
	
	func onMapObjectDragEnd(with mapObject: YMKMapObject) {
		guard let placemark = mapObject as? YMKPlacemarkMapObject,
			let annotation = placemark.cluster?.firstAnnotation as? MKPointAnnotation else {
				return
		}
		
		annotation.coordinate = placemark.geometry.coordinate
	}
	
	func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
		if let office = mapObject.userData as? Office {
			if viewModel.selectedOffice.value == office {
				dismissCurrentOffice()
			}
			else {
				if let selectedOffice = viewModel.selectedOffice.value {
					deselectOfficePin(office: selectedOffice)
				}
				selectOfficePin(office: office)
				centerMapObject(at: point)
				showModalOfficeInfo(office)
			}
		}
		else if mapObject.userData is Int { // Cluster tap
			centerMapObject(at: point, shouldShift: false, zoomDelta: 2.0)
		}
		else {
			return false
		}
		return true
	}
	
	/**
	*/
	@objc private func myLocationButtonTap() {
		guard let userLocation = viewModel.locationPosition.value else { return }
		map.move(with: YMKCameraPosition(target: YMKPoint(coordinate: userLocation.coordinate),
										 zoom: defaultZoomLevel, azimuth: 0, tilt: 0),
				 animationType: YMKAnimation(type: .smooth, duration: 0.5))
	}
	
	/**
	*/
	private func centerMapObject(at point: YMKPoint, shouldShift: Bool = true, zoomDelta: Double = 0) {
		let visibleCoordinatesHeight = map.visibleRegion.bottomLeft.latitude - map.visibleRegion.topLeft.latitude
		let coordinatesInScreenPoint = visibleCoordinatesHeight / Double(mapView.bounds.height)
		let pointShift = Double(mapView.bounds.height / 4) * coordinatesInScreenPoint
		map.move(
			with: YMKCameraPosition(
				target: YMKPoint(latitude: point.latitude + (shouldShift ? pointShift : 0), longitude: point.longitude),
				zoom: Float(mapView.zoom + zoomDelta), azimuth: 0, tilt: 0),
			animationType: YMKAnimation(type: .smooth, duration: 0.5))
	}
}

///
extension OfficesMapViewController: MapPopupViewDelegate {
	
	/**
	*/
	func mapPopupViewControllerShouldDismiss(_ viewController: MapPopupViewController) {
		dismissCurrentOffice(animated: false)
	}
}

private extension YMKPoint {
	convenience init(coordinate: CLLocationCoordinate2D) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
}
