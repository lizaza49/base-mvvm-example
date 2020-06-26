//
//  FormInputRadiobuttonOptionViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 28/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

///
protocol FormInputRadiobuttonOptionViewModelProtocol {
    var key: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var isSelected: BehaviorRelay<Bool> { get }
    var userToggleControlEvent: PublishSubject<String> { get }
    var disposeBag: DisposeBag { get }
    
    func toggleSelectionState()
}

///
class FormInputRadiobuttonOptionViewModel: FormInputRadiobuttonOptionViewModelProtocol {
    let key: String
    let title: String
    let subtitle: String?
    let isSelected: BehaviorRelay<Bool>
    let userToggleControlEvent: PublishSubject<String> = PublishSubject()
    let disposeBag = DisposeBag()
    
    init(key: String,
         title: String,
         subtitle: String? = nil,
         isSelected: Bool = false) {
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.isSelected = BehaviorRelay(value: isSelected)
    }
    
    func toggleSelectionState() {
        isSelected.accept(!isSelected.value)
        userToggleControlEvent.onNext(key)
    }
}
