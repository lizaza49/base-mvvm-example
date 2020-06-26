//
//  OfficeOfficeRouter.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 14/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

import Foundation

///
protocol OfficeRouterProtocol: BaseRouterProtocol {
	func showRoute(toOfficeAt lat: Double, lon: Double)
	func call(to officePhone: String)
}

///
extension OfficeRouterProtocol {
	
	/**
	*/
	func showRoute(toOfficeAt lat: Double, lon: Double) {
		let alertController = UIAlertController(title: nil, message: L10n.Common.Map.Route.message, preferredStyle: .actionSheet)
		alertController.view.tintColor = Color.cherry
		
		let lonLat = "\(lat),\(lon)"
		
		let googleMapsAction = UIAlertAction(title: L10n.Common.Map.Route.googleMaps, style: .default) { (action) in
			let appUrlProtocol = URL(string: "comgooglemaps://")!
			let appUrl = appUrlProtocol.appendingPathComponent("?daddr=\(lonLat)&directionsmode=walking")
			let iTunesUrl = URL(string: "itms-apps://itunes.apple.com/ru/app/google-maps-real-time-navigation/id585027354?mt=8")!
			if UIApplication.shared.canOpenURL(appUrlProtocol) {
				UIApplication.shared.open(appUrl)
			}
			else {
				UIApplication.shared.open(iTunesUrl)
			}
		}
		
		let yandexNavigatorAction = UIAlertAction(title: L10n.Common.Map.Route.yandexNavigator, style: .default) { (action) in
			let appUrlProtocol = URL(string: "yandexnavi://")!
			let appUrl = appUrlProtocol.appendingPathComponent("build_route_on_map?lat_to=\(lat)&lon_to=\(lon)")
			let iTunesUrl = URL(string: "https://itunes.apple.com/ru/app/yandeks.navigator/id474500851?mt=8")!
			if UIApplication.shared.canOpenURL(appUrlProtocol) {
				UIApplication.shared.open(appUrl)
			}
			else {
				UIApplication.shared.open(iTunesUrl)
			}
		}
		
		let appleMapsAction = UIAlertAction(title: L10n.Common.Map.Route.appleMaps, style: .default) { (action) in
			UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(lonLat)&dirflg=w")!)
		}
		
		alertController.addAction(googleMapsAction)
		alertController.addAction(yandexNavigatorAction)
		alertController.addAction(appleMapsAction)
		alertController.addAction(UIAlertAction(title: L10n.Common.Map.Route.cancel, style: .cancel, handler: nil))
		baseViewController?.present(alertController, animated: true, completion: nil)
	}
	
	func call(to officePhone: String) {
		UIApplication.shared.open(URL(string: "tel://\(officePhone.digits)")!)
	}
}

///
class OfficeRouter: BaseRouter, OfficeRouterProtocol { }

