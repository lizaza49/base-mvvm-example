//
//  FormInputRadiobuttonViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 28/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol FormInputRadiobuttonSelectorViewModelProtocol: AbstractFormInputViewModelProtocol {
    var options: [FormInputRadiobuttonOptionViewModelProtocol] { get }
    var selectedOptionKey: BehaviorSubject<String?> { get }
    var selectedIndex: Int? { get }
    var disposeBag: DisposeBag { get }
}

///
class FormInputRadiobuttonSelectorViewModel: FormInputRadiobuttonSelectorViewModelProtocol {
    
    let key: AbstractFormInputKey?
    let options: [FormInputRadiobuttonOptionViewModelProtocol]
    let selectedOptionKey: BehaviorSubject<String?>
    var selectedIndex: Int? {
        guard let selectedKey = (try? selectedOptionKey.value()) ?? nil else { return nil }
        return options.firstIndex(where: { $0.key == selectedKey })
    }
    let isRequired: Bool
    
    var inputIsValid: Bool {
        return isRequired ? ((try? selectedOptionKey.value()) ?? nil != nil) : true
    }
    var inputValidationSignal: PublishSubject<Bool> = PublishSubject()
    var next: AbstractFormInputViewModelProtocol?
    var prev: AbstractFormInputViewModelProtocol?
    let becomeResponderSignal = PublishSubject<Bool>()
    let inputHasChangedSignal = BehaviorSubject<Void?>(value: nil)
    var isResponder: Bool { return false }
    
    let disposeBag = DisposeBag()
    
    init(key: AbstractFormInputKey? = nil, options: [FormInputRadiobuttonOptionViewModelProtocol], selectedOptionKey: String? = nil, isRequired: Bool = true) {
        self.key = key
        self.options = options
        self.selectedOptionKey = BehaviorSubject(value: selectedOptionKey)
        if let selectedOptionKey = selectedOptionKey {
            options.first(where: { $0.key == selectedOptionKey })?.isSelected.accept(true)
        }
        self.isRequired = isRequired
        inputValidationSignal.onNext(inputIsValid)
        setupBindings()
    }
    
    /**
     */
    private func setupBindings() {
        selectedOptionKey.share().skipRepeats()
            .map { _ in () }
            .bind(to: inputHasChangedSignal)
            .disposed(by: disposeBag)
        
        selectedOptionKey.share().skipRepeats()
            .map { _ in self.inputIsValid }
            .bind(to: inputValidationSignal)
            .disposed(by: disposeBag)
        
        options.forEach {
            $0.userToggleControlEvent.subscribe(onNext: { key in
                guard
                    let targetOption = self.options.first(where: { $0.key == key }),
                    targetOption.isSelected.value
                else {
                    self.selectedOptionKey.onNext(nil)
                    return
                }
                self.options.forEach {
                    if $0.key != key && $0.isSelected.value {
                        $0.isSelected.accept(false)
                    }
                }
                self.selectedOptionKey.onNext(key)
            }).disposed(by: $0.disposeBag)
        }
    }
}
