//
//  FormInputFieldsFabric.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
class FormInputFieldsFabric {
    
    /**
     */
    static func phoneField(title: String?, placeholder: String?, initialValue: String? = nil) -> FormInputViewModel<String> {
        let phoneValidationMapper = PhoneValidationDataMapper()
        return FormInputViewModel<String>(
            title: title,
            placeholder: placeholder,
            maskDescriptor: FormInputMaskDescriptor(format: Constants.phoneInputMask),
            type: .keyboard(initialValue: initialValue),
            validator: InputValidatorsFabric.phone(),
            validationDataMapper: phoneValidationMapper,
            options: [.keyboardType(type: .phonePad)])
    }
    
    /**
     */
    static func emailField(title: String?, placeholder: String?, initialValue: String? = nil) -> FormInputViewModel<String> {
        let emailValidationMapper = EmailValidationDataMapper()
        return FormInputViewModel<String>(
            title: title,
            placeholder: placeholder,
            type: .keyboard(initialValue: initialValue),
            validator: InputValidatorsFabric.email(),
            validationDataMapper: emailValidationMapper,
            options: [.keyboardType(type: .emailAddress)])
    }
    
    /**
     */
    static func zipCodeField(title: String?, placeholder: String?, initialValue: String? = nil) -> FormInputViewModel<String> {
        return FormInputViewModel(
            title: title,
            placeholder: placeholder,
            maskDescriptor: .zipCode,
            type: .keyboard(initialValue: initialValue),
            validator: InputValidatorsFabric.regex(Regex.zipCode),
            options: [ .keyboardType(type: .numberPad) ])
    }
}
