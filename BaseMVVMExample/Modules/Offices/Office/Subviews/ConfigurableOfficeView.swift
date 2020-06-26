//
//  ConfigurableView.swift
//  BaseMVVMExample
//
//  Created by Admin on 01/02/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import UIKit

///
protocol ConfigurableOfficeView: class {
	associatedtype ViewModel
	
	static func estimatedHeight(for viewModel: ViewModel, superviewWidth: CGFloat) -> CGFloat
	func configure(with viewModel: ViewModel)
}
