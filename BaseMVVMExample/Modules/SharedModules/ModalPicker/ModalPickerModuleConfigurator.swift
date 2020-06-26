//
//  ModalPickerModalPickerModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
class ModalPickerModuleConfigurator {
    
    /**
     */
    static func configure(with vc: ModalPickerViewController) {
        let router = ModalPickerRouter(viewController: vc)
        vc.viewModel = ModalPickerViewModel(router: router)
    }
}
