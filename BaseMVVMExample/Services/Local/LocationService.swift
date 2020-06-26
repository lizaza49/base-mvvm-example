//
//  LocationService.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 09/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import CoreLocation
import YandexMapKit
import RxSwift

protocol LocationServiceProtocol {
	var authorizationStatus: Variable<Bool> { get }
	var currentLocation: Variable<YMKLocation?> { get }
	func requestAuthorization()
	func requestCurrentLocation()
	func startObservingLocation()
}

class LocationService: NSObject, LocationServiceProtocol {
	
	enum Constants {
		static let desiredAccuracy: Double = 0
		static let minTime: Int64 = 3000
		static let minDistance: Double = 10
		static let allowUseInBackground = true
	}
	
	var authorizationStatus: Variable<Bool> = Variable<Bool>(false)
	var currentLocation = Variable<YMKLocation?>(nil)
	
	private let locationManager : CLLocationManager
	private var yandexLocationManager : YMKLocationManager?
	override init() {
		yandexLocationManager = YMKMapKit.sharedInstance()?.createLocationManager()
		locationManager = CLLocationManager()
		super.init()
		locationManager.delegate = self
	}
	
	func requestCurrentLocation() {
		yandexLocationManager?.requestSingleUpdate(withLocationListener: self)
	}
	
	func startObservingLocation() {
		yandexLocationManager?.subscribeForLocationUpdates(withDesiredAccuracy: Constants.desiredAccuracy, minTime: Constants.minTime, minDistance: Constants.minDistance, allowUseInBackground: false, filteringMode: .off, locationListener: self)
	}
	
	func requestAuthorization() {
		let status = CLLocationManager.authorizationStatus()
		switch status {
		case .notDetermined:
			self.checkAuthorizationStatus()
		default:
			authorizationStatus.value = locationServiceEnabled(for: status)
		}
	}
	
	func checkAuthorizationStatus()
	{
		locationManager.requestWhenInUseAuthorization()
	}
	
	func locationServiceEnabled(for status: CLAuthorizationStatus) -> Bool
	{
		var enabled: Bool
		
		switch status {
		case .notDetermined:
			enabled = false
		case .restricted:
			enabled = false
		case .denied:
			enabled = false
		case .authorizedAlways:
			enabled = true
		case .authorizedWhenInUse:
			enabled = true
		}
		
		return enabled
	}
}

extension LocationService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		authorizationStatus.value = locationServiceEnabled(for: status)
	}
}

extension LocationService: YMKLocationDelegate {
	func onLocationUpdated(with location: YMKLocation) {
		Log.some("YMKLocation: \(location)")
		currentLocation.value = location
	}
	
	func onLocationStatusUpdated(with status: YMKLocationStatus) {
		Log.some("YMKLocationStatus: \(status)")
	}
}
