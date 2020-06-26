//
//  MapOfficesPinClusterViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 02/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation

///
protocol MapOfficiesPinClusterViewModelProtocol {
	var count: UInt { get }
}

///
struct MapOfficiesPinClusterViewModel: MapOfficiesPinClusterViewModelProtocol {
	let count: UInt
}
