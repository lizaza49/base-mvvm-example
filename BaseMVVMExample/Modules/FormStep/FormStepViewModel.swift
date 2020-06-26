//
//  BaseFormStepBaseFormStepViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

///
protocol FormStepViewModelProtocol {
    var router: FormStepRouterProtocol { get }
    var step: BaseFormStepProtocol { get }
    var heading: FormStepHeadingViewModelProtocol? { get }
    var inputs: [AbstractFormInputViewModelProtocol] { get }
    var filledWithValidData: Variable<Bool> { get }
    
    var customButtonText: BehaviorRelay<String?> { get }
    var customButtonAction: ((BaseFormRouterProtocol) -> Void)? { get }
    
    var disposeBag: DisposeBag { get }
}

///
class FormStepViewModel: NSObject, FormStepViewModelProtocol {

    var router: FormStepRouterProtocol
    var step: BaseFormStepProtocol
    var heading: FormStepHeadingViewModelProtocol?
    var inputs: [AbstractFormInputViewModelProtocol] {
        didSet {
            inputs.chain()
        }
    }
    let filledWithValidData = Variable<Bool>(false)
    
    let customButtonText = BehaviorRelay<String?>(value: nil)
    var customButtonAction: ((BaseFormRouterProtocol) -> Void)?
    
    var disposeBag = DisposeBag()
    private var validationDisposable: Disposable?
    
    ///
    var inputsAreValid: Bool {
        let validationFlags = self.inputs.map { $0.inputIsValid }
        return validationFlags.reduce(true, { $0 && $1 })
    }
    
    init(router: FormStepRouterProtocol,
         step: BaseFormStepProtocol,
         heading: FormStepHeadingViewModelProtocol?,
         inputs: [AbstractFormInputViewModelProtocol]) {
        self.router = router
        self.step = step
        self.heading = heading
        self.inputs = inputs
        super.init()
        setupBindings()
        performInputsValidation()
    }
    
    /**
     */
    func setupBindings() {
        resetValidationObserver()
    }
    
    /**
     */
    func resetValidationObserver() {
        validationDisposable?.dispose()
        validationDisposable = Observable.combineLatest(inputs.map { $0.inputHasChangedSignal })
            .subscribe(onNext: { _ in self.performInputsValidation() })
        
        disposeBag.insert(validationDisposable!)
    }
    
    /**
     */
    func insert(item: AbstractFormInputViewModelProtocol, at index: Int) {
        guard (0 ... inputs.count) ~= index else { return }
        inputs.insert(item, at: index)
        inputs.chain()
        resetValidationObserver()
    }
    
    /**
     */
    func delete(itemAt index: Int) {
        guard (0 ..< inputs.count) ~= index else { return }
        inputs.remove(at: index)
        inputs.chain()
        resetValidationObserver()
    }
    
    /**
     */
    func performInputsValidation() {
        filledWithValidData.value = inputsAreValid
    }
}
