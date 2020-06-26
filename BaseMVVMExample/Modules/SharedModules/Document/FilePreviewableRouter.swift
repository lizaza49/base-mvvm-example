//
//  FilePreviewableRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import QuickLook

///
protocol FilePreviewableRouterProtocol: BaseRouterProtocol {}

///
extension FilePreviewableRouterProtocol {
    
    /**
     */
    func previewFile(_ fileViewModel: FileViewModelProtocol) {
        let vc = DocumentViewController()
        let router = DocumentRouter(viewController: vc)
        vc.viewModel = DocumentViewModel(router: router, fileId: fileViewModel.id, title: fileViewModel.name)
        show(viewController: vc)
    }
}
