//
//  MapObjectVisitor.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import YandexMapKit

///
enum MapObjectLookupStrategy {
	case placemark(negateResults: Bool)
}

///
typealias MapObjectLookupResultBlock = (YMKMapObject) -> Void

///
class MapObjectLookupManager<UserDataType: Hashable>: NSObject, YMKMapObjectVisitor {
	
	///
	private let userData: Set<UserDataType>
	var strategy: MapObjectLookupStrategy
	var resultBlock: MapObjectLookupResultBlock?
	
	/**
	*/
	init(userData: UserDataType, strategy: MapObjectLookupStrategy) {
		self.userData = Set([userData])
		self.strategy = strategy
	}
	
	/**
	*/
	init(userDataSet: Set<UserDataType>, strategy: MapObjectLookupStrategy) {
		self.userData = userDataSet
		self.strategy = strategy
	}
	
	/**
	*/
	func traverse(objects: YMKMapObjectCollection, resultBlock: @escaping  MapObjectLookupResultBlock) {
		self.resultBlock = resultBlock
		objects.traverse(with: self)
	}
	
	/**
	*/
	func traverseAll(objects: YMKMapObjectCollection, resultBlock: @escaping  MapObjectLookupResultBlock) {
		self.resultBlock = resultBlock
		objects.traverse(with: self)
	}
	
	/**
	*/
	func onPlacemarkVisited(withPlacemark placemark: YMKPlacemarkMapObject) {
		switch strategy {
		case .placemark(let negateResults):
			guard let userData = placemark.userData as? UserDataType else { return }
			if self.userData.contains(userData) != negateResults {
				resultBlock?(placemark)
			}
		}
	}
	
	func onPolylineVisited(withPolyline polyline: YMKPolylineMapObject) {}
	
	func onColoredPolylineVisited(withPolyline polyline: YMKColoredPolylineMapObject) {}
	
	func onPolygonVisited(withPolygon polygon: YMKPolygonMapObject) {}
	
	func onCircleVisited(withCircle circle: YMKCircleMapObject) {}
	
	func onCollectionVisitStart(with collection: YMKMapObjectCollection) -> Bool {
		return resultBlock != nil
	}
	
	func onCollectionVisitEnd(with collection: YMKMapObjectCollection) {}
}
