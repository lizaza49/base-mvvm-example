//
//  OfficeOfficeAnnotation.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 11/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import ClusterKit

class MapOfficeAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: office.lat, longitude: office.lon)
	}
	let office: Office
	
	init(office: Office) {
		self.office = office
	}
	
	static func pinAsset(isSelected: Bool) -> ImageAsset {
		return isSelected ? Asset.Map.pinFocused : Asset.Map.pinNormal
	}
}
