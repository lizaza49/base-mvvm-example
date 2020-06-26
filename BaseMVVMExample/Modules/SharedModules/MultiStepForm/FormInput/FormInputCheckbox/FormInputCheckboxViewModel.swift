//
//  FormInputCheckboxViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 22/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol FormInputCheckboxViewModelProtocol: AbstractFormInputViewModelProtocol {
    var text: String { get }
    var checked: Variable<Bool> { get }
    var isRequired: Bool { get }
    var disposeBag: DisposeBag { get }
}

///
class FormInputCheckboxViewModel: FormInputCheckboxViewModelProtocol {

    var inputIsValid: Bool {
        return isRequired ? checked.value : true
    }
    
    var key: AbstractFormInputKey?
    var inputValidationSignal: PublishSubject<Bool>
    let text: String
    let checked: Variable<Bool>
    let isRequired: Bool
    var next: AbstractFormInputViewModelProtocol?
    var prev: AbstractFormInputViewModelProtocol?
    let becomeResponderSignal = PublishSubject<Bool>()
    let inputHasChangedSignal = BehaviorSubject<Void?>(value: nil)
    var isResponder: Bool { return false }
    
    let disposeBag = DisposeBag()
    
    init(key: AbstractFormInputKey? = nil, text: String, checked: Bool, isRequired: Bool) {
        self.key = key
        self.text = text
        self.checked = Variable(checked)
        self.isRequired = isRequired
        inputValidationSignal = PublishSubject()
        inputValidationSignal.onNext(isRequired ? checked : true)
        self.checked.asObservable().share()
            .map { isRequired ? $0 : true }
            .bind(to: inputValidationSignal)
            .disposed(by: disposeBag)
        self.checked.asObservable().share()
            .skipRepeats()
            .map {  _ in return () }
            .bind(to: inputHasChangedSignal)
            .disposed(by: disposeBag)
    }
}
