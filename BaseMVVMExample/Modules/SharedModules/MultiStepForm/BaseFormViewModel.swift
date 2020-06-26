//
//  BaseFormBaseFormViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

///
protocol BaseFormStepProtocol {
    var rawValue: Int { get }
    init?(rawValue: Int)
}

///
extension BaseFormStepProtocol {
    var isLast: Bool {
        return Self.init(rawValue: rawValue + 1) == nil
    }
}


///
protocol BaseFormViewModelProtocol: BaseViewModelProtocol {
    var router: BaseFormRouterProtocol { get }
    var formSteps: [FormStepViewModelProtocol] { get }
    var currentStep: Variable<BaseFormStepProtocol> { get }
    var buttonText: Variable<String> { get }
    var buttonIsEnabled: BehaviorRelay<Bool> { get }
    var currentStepIndex: Int? { get }
    var isLoading: Variable<Bool> { get }
    
    init(router: BaseFormRouterProtocol,
         formSteps: [FormStepViewModelProtocol],
         initialStep: BaseFormStepProtocol,
         continueButtonText: String,
         submitButtonText: String)
    
    func index(of step: BaseFormStepProtocol) -> Int?
    func viewDidTapBack()
    func viewDidTapContinue()
}

///
class BaseFormViewModel: BaseViewModel, BaseFormViewModelProtocol {
    
    let router: BaseFormRouterProtocol
    let formSteps: [FormStepViewModelProtocol]
    let currentStep: Variable<BaseFormStepProtocol>
    let buttonText: Variable<String>
    let buttonIsEnabled: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isLoading = Variable<Bool>(false)
    private let continueButtonText: String
    private let submitButtonText: String
    
    private var stepValidationObserver: Disposable?
    private var stepButtonTextObserver: Disposable?
    
    // MARK: Calculated properties
    private var currentStepViewModel: FormStepViewModelProtocol? {
        guard let index = self.index(of: currentStep.value) else { return nil }
        return formSteps[index]
    }
    
    ///
    var currentStepIndex: Int? {
        return index(of: currentStep.value)
    }
    
    ///
    var defaultButtonText: String {
        return currentStep.value.isLast ? self.submitButtonText : self.continueButtonText
    }
    
    /**
     */
    required init(router: BaseFormRouterProtocol,
                  formSteps: [FormStepViewModelProtocol],
                  initialStep: BaseFormStepProtocol,
                  continueButtonText: String,
                  submitButtonText: String) {
        self.router = router
        self.formSteps = formSteps
        self.currentStep = Variable(initialStep)
        self.continueButtonText = continueButtonText
        self.submitButtonText = submitButtonText
        buttonText = Variable(initialStep.isLast ? submitButtonText : continueButtonText)
        super.init()
        setupBindings()
    }
    
    /**
     */
    private func setupBindings() {
        currentStep.asObservable()
            .takeUntil(rx.deallocated)
            .subscribe(onNext: {
                self.buttonText.value = $0.isLast ? self.submitButtonText : self.continueButtonText
                self.setupStepObservers()
        }).disposed(by: disposeBag)
        setupStepObservers()
    }
    
    /**
     */
    private func setupStepObservers() {
        stepValidationObserver?.dispose()
        stepValidationObserver = currentStepViewModel?.filledWithValidData
            .asObservable()
            .bind(to: buttonIsEnabled)
        
        stepButtonTextObserver?.dispose()
        stepButtonTextObserver = currentStepViewModel?.customButtonText
            .map { ($0 == nil) ? self.defaultButtonText : $0! }
            .bind(to: buttonText)
    }
    
    /**
     */
    func index(of step: BaseFormStepProtocol) -> Int? {
        return formSteps.enumerated().first(where: { $0.element.step.rawValue == step.rawValue })?.offset
    }

    /**
     */
    func viewDidTapBack() {
        guard let currentStepIndex = index(of: currentStep.value) else { return }
        if currentStepIndex == 0 {
            router.pop()
        }
        else if (0 ..< formSteps.count) ~= (currentStepIndex - 1) {
            currentStep.value = formSteps[currentStepIndex - 1].step
        }
    }
    
    /**
     */
    func viewDidTapContinue() {
        if let customAction = currentStepViewModel?.customButtonAction {
            customAction(router)
            return
        }
        guard let currentStepIndex = index(of: currentStep.value) else { return }
        if currentStepIndex == formSteps.count - 1 {
            submitForm()
        }
        else if (currentStepIndex < formSteps.count - 1) {
            currentStep.value = formSteps[currentStepIndex + 1].step
        }
    }
    
    /**
     To be overriden
     */
    func submitForm() {}
}
