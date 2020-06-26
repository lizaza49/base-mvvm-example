//
//  FullNameInputStepViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

fileprivate typealias Texts = L10n.Common.FullNamePicker

///
enum FullNameInputStep: Int, BaseFormStepProtocol {
    case form = 0
}

///
protocol FullNameInputStepViewModelProtocol: FormStepViewModelProtocol {
    var screenTitle: String { get }
    func viewDidTapApplyButton()
}

///
class FullNameInputStepViewModel: FormStepViewModel, FullNameInputStepViewModelProtocol {
    
    let screenTitle: String
    
    private let splitter = " "
    private let numberOfComponents = 3
    private let fullName: FullName
    private let fullNameSubmissionSignal: PublishSubject<FullName> = PublishSubject()
    
    /**
     */
    init(router: FormStepRouterProtocol, output: Variable<FullName?>, screenTitle: String) {
        self.screenTitle = screenTitle
        self.fullName = output.value ?? FullName()
        super.init(router: router, step: FullNameInputStep.form, heading: nil, inputs: [])
        
        let lastNameField = createInputField(with: Texts.LastName.title, placeholder: Texts.LastName.placeholder, value: output.value?.last.value)
        lastNameField.value.asObservable().share().bind(to: fullName.last).disposed(by: lastNameField.disposeBag)
        
        let firstNameField = createInputField(with: Texts.FirstName.title, placeholder: Texts.FirstName.placeholder, value: output.value?.first.value)
        firstNameField.value.asObservable().share().bind(to: fullName.first).disposed(by: firstNameField.disposeBag)
        
        let middleNameField = createInputField(with: Texts.Patronymic.title, placeholder: Texts.Patronymic.placeholder, value: output.value?.middle.value)
        middleNameField.value.asObservable().share().bind(to: fullName.middle).disposed(by: middleNameField.disposeBag)
        
        self.inputs = [lastNameField, firstNameField, middleNameField]
        setupBindings(output: output)
    }
    
    /**
     */
    func setupBindings(output: Variable<FullName?>) {
        super.setupBindings()
        fullNameSubmissionSignal.bind(to: output).disposed(by: disposeBag)
    }
    
    /**
     */
    private func createInputField(with title: String, placeholder: String, value: String?) -> FormInputViewModel<String> {
        let validationMapper = FullNameValidationDataMapper()
        let field = FormInputViewModel<String>(
            title: title,
            placeholder: placeholder,
            type: .keyboard(initialValue: value),
            validator: StringValidator(regex: Regex.fullNameComponent, isRequired: true),
            validationDataMapper: validationMapper,
            options: [.autocapitalization(type: .words)])
        return field
    }
    
    /**
     */
    func viewDidTapApplyButton() {
        defer { router.pop() }
        guard filledWithValidData.value else {
             // Impossible case
            Log.some(RGSError.message("Apply button is enabled while `filledWithValidData` is false"))
            return
        }
        self.fullNameSubmissionSignal.onNext(fullName)
    }
}
