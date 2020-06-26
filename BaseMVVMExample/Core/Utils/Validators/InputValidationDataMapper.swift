//
//  InputValidationDataMapper.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
protocol InputValidationDataMapperProtocol {
    associatedtype InputData
    func map(_ data: InputData?) -> InputData?
}

///
class InputValidationDataMapper<InputDataType>: InputValidationDataMapperProtocol {
    typealias InputData = InputDataType
    func map(_ data: InputData?) -> InputData? { return data }
}


///
class TrimmingEmptyValidationDataMapper: InputValidationDataMapper<String> {
    /**
     */
    override func map(_ data: InputData?) -> InputData? {
        guard let data = data else { return nil }
        return data.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

///
class UppercasedValidationDataMapper: InputValidationDataMapper<String> {
    /**
     */
    override func map(_ data: InputData?) -> InputData? {
        guard let data = data else { return nil }
        return data.uppercased()
    }
}

///
class PhoneValidationDataMapper: InputValidationDataMapper<String> {
    /**
     */
    override func map(_ data: InputData?) -> InputData? {
        guard let data = data else { return nil }
        return String(data.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().dropFirst())
    }
}

///
class EmailValidationDataMapper: InputValidationDataMapper<String>  {
    /**
     */
    override func map(_ data: InputData?) -> InputData? {
        guard let data = data else { return nil }
        return data.lowercased()
    }
}

///
class FullNameValidationDataMapper: InputValidationDataMapper<String>  {
    /**
     */
    override func map(_ data: InputData?) -> InputData? {
        guard let data = data else { return nil }
        return data.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().capitalized
    }
}

///
class PassportValidationDataMapper: InputValidationDataMapper<String>  {
    /**
     */
    override func map(_ data: InputData?) -> InputData? {
        guard let data = data else { return nil }
        return data.replacingOccurrences(of: "-", with: " ")
    }
}
