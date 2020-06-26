//
//  FullNameInputPresentableRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol FullNameInputPresentableRouterProtocol: BaseRouterProtocol {
    func showFullNameInput(bindingTarget: Variable<FullName?>, screenTitle: String)
}

///
extension FullNameInputPresentableRouterProtocol {
    
    /**
     */
    func showFullNameInput(bindingTarget: Variable<FullName?>, screenTitle: String) {
        let vc = FullNameInputStepViewController()
        FullNameInputStepConfigurator.configure(with: vc, screenTitle: screenTitle, bindingTarget: bindingTarget)
        show(viewController: vc)
    }
}
