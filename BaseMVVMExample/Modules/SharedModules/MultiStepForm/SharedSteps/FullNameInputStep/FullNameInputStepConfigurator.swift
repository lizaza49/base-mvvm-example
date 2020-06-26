//
//  FullNameInputStepConfigurator.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
class FullNameInputStepConfigurator {
    
    /**
     */
    static func configure(with vc: FullNameInputStepViewController, screenTitle: String, bindingTarget: Variable<FullName?>) {
        let router = FormStepRouter(viewController: vc)
        vc.viewModel = FullNameInputStepViewModel(router: router, output: bindingTarget, screenTitle: screenTitle)
    }
}
