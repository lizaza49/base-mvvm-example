//
//  FormStepHeadingViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol FormStepHeadingViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
}

///
struct FormStepHeadingViewModel: FormStepHeadingViewModelProtocol {
    var title: String
    var subtitle: String
}
