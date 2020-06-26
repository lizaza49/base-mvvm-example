//
//  StringValidators.swift
//  BaseMVVMExample
//
//  Created by Admin on 10/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol StringValidatorProtocol: InputValidatorProtocol where TypeToValidate: StringConvertible {
    
}

///
extension StringValidatorProtocol {
    
    /**
     */
    func performDefaultValidation(_ input: TypeToValidate?) -> Bool {
        if (input == nil || input!.asString.isEmpty) && !isRequired { return true }
        guard let input = input?.asString, !input.isEmpty else { return false }
        guard let regex = self.regex, !regex.isEmpty else { return true }
        do {
            let regularExpression = try NSRegularExpression(pattern: regex)
            let match = regularExpression.firstMatch(in: input, range: NSRange(location: 0, length: input.count))
            return match != nil
        }
        catch {
            let err = "Error: invalid regex \(regex)"
            DDLogError(context: .evna, message: "runtime_error", params: [ "file" : #file, "function" : #function, "error" : err ], error: nil)
            return false
        }
    }
}

///
class StringValidator<ValidationTargetType: StringConvertible>: InputValidator<ValidationTargetType>, StringValidatorProtocol {
    typealias TypeToValidate = ValidationTargetType
    
    /**
     */
    init(regex: String? = nil, isRequired: Bool) {
        super.init()
        self.regex = regex
        self.isRequired = isRequired
    }
    
    /**
     */
    override func validate(_ input: ValidationTargetType?) -> Bool {
        return performDefaultValidation(input)
    }
}

///
class MultiRegexStringValidator<ValidationTargetType: StringConvertible>: InputValidator<ValidationTargetType>, StringValidatorProtocol {
    typealias TypeToValidate = ValidationTargetType
    private var regexes: [String]
    
    /**
     */
    init(regexes: [String], isRequired: Bool) {
        self.regexes = regexes
        super.init()
        self.regex = nil
        self.isRequired = isRequired
    }
    
    /**
     */
    override func validate(_ input: ValidationTargetType?) -> Bool {
        let validators = regexes.map { StringValidator<ValidationTargetType>(regex: $0, isRequired: isRequired) }
        return validators.reduce(true, { $0 && $1.validate(input) })
    }
}

///
final class EmailValidator: StringValidator<String> {
    ///
    override var regex: String? {
        get {
            return "^((([a-z]|\\d|[!#\\$%&'\\*\\+\\-\\/=\\?\\^_`{\\|}~])+(\\.([a-z]|\\d|[!#\\$%&'\\*\\+\\-\\/=\\?\\^_`{\\|}~])+)*)|((\\x22)((((\\x20|\\x09)*(\\x0d\\x0a))?(\\x20|\\x09)+)?(([\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x7f]|\\x21|[\\x23-\\x5b]|[\\x5d-\\x7e])|(\\\\([\\x01-\\x09\\x0b\\x0c\\x0d-\\x7f]))))*(((\\x20|\\x09)*(\\x0d\\x0a))?(\\x20|\\x09)+)?(\\x22)))@((([a-z]|\\d)|(([a-z]|\\d)([a-z]|\\d|-|\\.|_|~)*([a-z]|\\d)))\\.)+(([a-z])|(([a-z])([a-z]|\\d|-|\\.|_|~)*([a-z])))$"
        }
        set {}
    }
}

///
final class PhoneValidator: StringValidator<String> {
    ///
    override var regex: String? {
        get {
            return "^\\d{10}$"
        }
        set {}
    }
}

///
final class VehicleVinValidator: InputValidator<String> {
    
    /**
     */
    override func validate(_ input: String?) -> Bool {
        guard let input = input?.uppercased() else { return false }
        let charSet = CharacterSet(charactersIn: input)
        guard
            input.count == 17,
            charSet.isDisjoint(with: CharacterSet(charactersIn: "QOI")),
            !charSet.isDisjoint(with: .latinUppercased),
            !charSet.isDisjoint(with: .digits) else { return false }
        
        // check if there are not more than n equal chars in a row
        let n = 8
        for i in 0 ..< (input.count - n + 1) {
            var substring = String(input[(i ... (i + n - 1))])
            substring = substring.replacingOccurrences(of: String(substring.first!), with: "")
            if substring.isEmpty { return false }
        }
        return true
    }
}

///
final class VehicleBodyNumberValidator: InputValidator<String> {
    
    /**
     */
    override func validate(_ input: String?) -> Bool {
        guard let input = input?.uppercased() else { return false }
        let charSet = CharacterSet(charactersIn: input)
        guard
            (1 ... 24) ~= input.count,
            !(input.first == "-"), !(input.last == "-"),
            (0 ... 1) ~= (input.count - input.replacingOccurrences(of: "-", with: "").count),
            charSet.subtracting(.latinUppercased).subtracting(.digits).subtracting(CharacterSet(charactersIn: "-")).isEmpty
        else { return false }
        
        // check if there are not more than n equal chars in a row
        let n = 8
        guard input.count >= n else { return true }
        for i in 0 ..< (input.count - n + 1) {
            var substring = String(input[(i ... (i + n - 1))])
            substring = substring.replacingOccurrences(of: String(substring.first!), with: "")
            if substring.isEmpty { return false }
        }
        return true
    }
}

