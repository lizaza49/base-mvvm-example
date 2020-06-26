//
//  BaseViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol BaseViewModelProtocol {
    var disposeBag: DisposeBag { get }
}

///
class BaseViewModel: NSObject, BaseViewModelProtocol {
    let disposeBag = DisposeBag()
}
