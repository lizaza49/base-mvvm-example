//
//  FormInputCustomPickerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

///
protocol FormInputCustomPickerViewModelProtocol: AbstractFormInputViewModelProtocol {
    var heading: String { get }
    var title: BehaviorRelay<String?> { get }
    var subtitle: BehaviorRelay<String?> { get }
    var placeholder: String { get }
    var onTap: (() -> Void)? { get }
    var disposeBag: DisposeBag { get }
}

///
class FormInputCustomPickerViewModel: FormInputCustomPickerViewModelProtocol {
    let heading: String
    let title: BehaviorRelay<String?>
    let subtitle: BehaviorRelay<String?>
    let placeholder: String
    let onTap: (() -> Void)?
    
    let key: AbstractFormInputKey?
    weak var next: AbstractFormInputViewModelProtocol?
    weak var prev: AbstractFormInputViewModelProtocol?
    let becomeResponderSignal = PublishSubject<Bool>()
    var inputIsValid: Bool {
        return isRequired ? (self.title.value != nil) : true
    }
    var isResponder: Bool { return true }
    
    let inputHasChangedSignal = BehaviorSubject<Void?>(value: nil)
    let inputValidationSignal = PublishSubject<Bool>()
    let disposeBag = DisposeBag()
    
    private var isRequired: Bool
    
    init(key: AbstractFormInputKey? = nil, heading: String, title: String?, subtitle: String?, placeholder: String, onTap: (() -> Void)?, isRequired: Bool = true) {
        self.key = key
        self.heading = heading
        self.title = BehaviorRelay(value: title)
        self.subtitle = BehaviorRelay(value: subtitle)
        self.placeholder = placeholder
        self.onTap = onTap
        self.isRequired = isRequired
        setupBindings()
    }
    
    /**
     */
    private func setupBindings() {
        Observable.combineLatest([title.asObservable(), subtitle.asObservable()])
            .map { _ in return ()}
            .bind(to: inputHasChangedSignal)
            .disposed(by: disposeBag)
    }
}
