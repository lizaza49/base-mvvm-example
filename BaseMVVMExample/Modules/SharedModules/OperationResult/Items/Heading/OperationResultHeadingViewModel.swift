//
//  OperationResultHeadingViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol OperationResultHeadingViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var type: OperationResultType { get }
}

///
class OperationResultHeadingViewModel: OperationResultHeadingViewModelProtocol {
    let title: String
    let subtitle: String
    let type: OperationResultType
    
    init(title: String,
        subtitle: String,
        type: OperationResultType) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}
