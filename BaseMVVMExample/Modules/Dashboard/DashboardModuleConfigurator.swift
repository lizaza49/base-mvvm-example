//
//  DashboardModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Admin on 28/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
class DashboardModuleConfigurator {
    
    static func configure(with vc: DashboardViewController) {
        let router = DashboardRouter(viewController: vc)
        vc.viewModel = DashboardViewModel(router: router)
    }
}
