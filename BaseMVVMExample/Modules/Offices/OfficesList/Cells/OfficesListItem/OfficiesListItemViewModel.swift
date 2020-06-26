//
//  OfficesListItemViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import UIKit

///
protocol OfficiesListItemViewModelProtocol {
	var officeViewModel: OfficeViewModelProtocol { get }
	var superVC: UIViewController { get }
}

///
class OfficiesListItemViewModel: OfficiesListItemViewModelProtocol {
	let officeViewModel: OfficeViewModelProtocol
	let superVC: UIViewController
	
	init(officeViewModel: OfficeViewModelProtocol, superVC: UIViewController) {
		self.officeViewModel = officeViewModel
		self.superVC = superVC
	}
}
