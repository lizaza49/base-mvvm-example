//
//  InputValidator.swift
//  BaseMVVMExample
//
//  Created by Admin on 10/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol InputValidatorProtocol {
    associatedtype TypeToValidate
    
    var regex: String? { get }
    var isRequired: Bool { get }
    func validate(_ input: TypeToValidate?) -> Bool
}

///
class InputValidator<TargetType>: InputValidatorProtocol {
    typealias TypeToValidate = TargetType
    var regex: String? = nil
    var isRequired: Bool = false
    func validate(_ input: TypeToValidate?) -> Bool { return true }
}

///
struct InputValidatorsFabric {
    static let nonEmptyString = StringValidator<String>(isRequired: true)
    static let fullName = StringValidator<FullName>(regex: Regex.fullName, isRequired: true)
    static func notNil<T: StringConvertible>() -> StringValidator<T> {
        return StringValidator(isRequired: true)
    }
    static func email(isRequired: Bool = true) -> EmailValidator {
        return EmailValidator(isRequired: isRequired)
    }
    static func phone(isRequired: Bool = true) -> PhoneValidator {
        return PhoneValidator(isRequired: isRequired)
    }
    static func regex(_ regex: String, isRequired: Bool = true) -> StringValidator<String> {
        return StringValidator<String>(regex: regex, isRequired: isRequired)
    }
    static func date<ValidationType: DateRepresentable>(acceptableRange: ClosedRange<Date>, isRequired: Bool = true) -> DateValidator<ValidationType> {
        return DateValidator(acceptableRange: acceptableRange, isRequired: isRequired)
    }
    static func multiRegex(_ regexes: [String], isRequired: Bool = true) -> MultiRegexStringValidator<String> {
        return MultiRegexStringValidator(regexes: regexes, isRequired: isRequired)
    }
    static func validPolicyType() -> StringValidator<PolicyType.Kind> {
        return StringValidator<PolicyType.Kind>(isRequired: true)
    }
}

///
struct Regex {
    static let fullName = "^([А-Я]{1}[а-я]+ ){2}[А-Я]{1}[а-я]+$"
    static let fullNameComponent = "^[А-Я]{1}[а-я]+$"
    static let zipCode = "^[0-9]{6}$"
    static let houseApt = "^[-ЁА-Яёа-я\\d .,/]*$"
    static let policyFullNumber = "^((А{3})|(В{3})|(С{3})|(Е{3})|(Х{3})|(К{3})|(М{3})) \\d{10}$"
    static let driverLicence = "^\\d{2}[0-9A-Za-zА-Яа-я]{2}[ ]\\d{6}$"
    static let enginePower = "^\\d{1,5}(\\.\\d{1}){0,1}$"
    static let vehicleRegistrationNumber = "^([0-9АВЕКМНОРСТУХ]){0,1}\\d{3}([0-9АВЕКМНОРСТУХ]){0,2}\\d{2,3}$"
}
