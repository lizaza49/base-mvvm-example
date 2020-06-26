//
//  HiddenInfoToggleViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 25/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol HiddenInfoToggleViewModelProtocol {
    var title: String { get }
    var isExpanded: BehaviorSubject<Bool> { get }
    
    func toggleExpansionState()
}

///
class HiddenInfoToggleViewModel: HiddenInfoToggleViewModelProtocol {
    var title: String
    var isExpanded: BehaviorSubject<Bool>
    
    init(title: String, isExpanded: Bool = false) {
        self.title = title
        self.isExpanded = BehaviorSubject(value: isExpanded)
    }
    
    func toggleExpansionState() {
        let currentState = ((try? isExpanded.value()) ?? false)
        isExpanded.onNext(!currentState)
    }
}
