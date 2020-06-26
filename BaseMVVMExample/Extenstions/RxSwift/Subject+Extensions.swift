//
//  Subject+Extensions.swift
//  BaseMVVMExample
//
//  Created by Admin on 24/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
extension BehaviorSubject {
    
    /**
     */
    func emit() {
        guard let value = try? value() else { return }
        self.onNext(value)
    }
}
