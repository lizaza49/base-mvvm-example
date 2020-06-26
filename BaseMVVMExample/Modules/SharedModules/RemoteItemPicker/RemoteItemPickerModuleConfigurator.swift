//
//  AddressPickerModuleConfigurator.swift
//  BaseMVVMExample
//
//  Created by Admin on 18/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
class RemoteItemPickerModuleConfigurator {
    
    /**
     */
    static func configure<SearchableItem: SearchableRemoteItemProtocol>(
        vc: RemoteItemPickerViewController,
      strategy: RemoteItemPickerStrategy,
      screenTitle: String,
      initialValue: String,
      output: Variable<SearchableItem?>) {
        let router = RemoteItemPickerRouter(viewController: vc)
        vc.viewModel = RemoteItemPickerViewModel(
            router: router,
            strategy: strategy,
            screenTitle: screenTitle,
            initialValue: initialValue,
            output: output)
    }
}
