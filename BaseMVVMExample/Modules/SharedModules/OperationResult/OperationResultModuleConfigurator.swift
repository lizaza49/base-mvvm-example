//
//  OperationResultModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
class OperationResultModuleConfigurator {
    
    /**
     - parameter stickyButtons: ordered bottom > top
     */
    static func configure(
        with vc: OperationResultViewController,
        title: String,
        subtitle: String,
        type: OperationResultType,
        content: String,
        expansionButton: String? = nil,
        hiddenContent: String? = nil,
        stickyButtons: [OperationResultStickyButtonViewModel]) {
        let router = OperationResultRouter(viewController: vc)
        vc.viewModel = OperationResultViewModel(
            router: router,
            title: title,
            subtitle: subtitle,
            type: type,
            content: content,
            expansionButton: expansionButton,
            hiddenContent: hiddenContent,
            stickyButtons: stickyButtons)
    }
}
