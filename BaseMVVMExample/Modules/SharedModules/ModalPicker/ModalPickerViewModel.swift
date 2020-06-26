//
//  ModalPickerModalPickerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol ModalPickerViewModelProtocol: BaseViewModelProtocol {
	var router: ModalPickerRouterProtocol { get }
}

///
final class ModalPickerViewModel: BaseViewModel, ModalPickerViewModelProtocol {
    
    ///
    let router: ModalPickerRouterProtocol

    /**
     */
    init(router: ModalPickerRouterProtocol) {
    	self.router = router
    	super.init()
    }
}