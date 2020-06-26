//
//  OperationResultOperationResultViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
enum OperationResultType {
    case success
    case failure
}

///
struct OperationResultStickyButtonViewModel {
    var style: StickyButtonStyle
    var text: String
    var action: (BaseRouterProtocol) -> Void
}

///
protocol OperationResultViewModelProtocol: BaseViewModelProtocol {
    var router: OperationResultRouterProtocol { get }
    var heading: OperationResultHeadingViewModelProtocol { get }
    var content: String { get }
    var hiddenInfoViewModel: HiddenInfoToggleViewModelProtocol? { get }
    var boxedInfoViewModel: BoxedInfoViewModelProtocol? { get }
    var stickyButtons: [OperationResultStickyButtonViewModel] { get }
}

///
final class OperationResultViewModel: BaseViewModel, OperationResultViewModelProtocol {
    let router: OperationResultRouterProtocol
    let heading: OperationResultHeadingViewModelProtocol
    let content: String
    let hiddenInfoViewModel: HiddenInfoToggleViewModelProtocol?
    let boxedInfoViewModel: BoxedInfoViewModelProtocol?
    let stickyButtons: [OperationResultStickyButtonViewModel]
    
    init(router: OperationResultRouterProtocol,
         title: String,
         subtitle: String,
         type: OperationResultType,
         content: String,
         expansionButton: String? = nil,
         hiddenContent: String? = nil,
         stickyButtons: [OperationResultStickyButtonViewModel]) {
        self.router = router
        heading = OperationResultHeadingViewModel(title: title, subtitle: subtitle, type: type)
        self.content = content
        if let expansionButton = expansionButton, let hiddenContent = hiddenContent {
            self.hiddenInfoViewModel = HiddenInfoToggleViewModel(title: expansionButton)
            self.boxedInfoViewModel = BoxedInfoViewModel(text: hiddenContent)
        }
        else {
            self.hiddenInfoViewModel = nil
            self.boxedInfoViewModel = nil
        }
        self.stickyButtons = stickyButtons
        super.init()
    }
}
