//
//  DateValidators.swift
//  BaseMVVMExample
//
//  Created by Admin on 20/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol DateValidatorProtocol: InputValidatorProtocol where TypeToValidate: DateRepresentable {}

///
///
class DateValidator<ValidationTargetType: DateRepresentable>: InputValidator<ValidationTargetType>, DateValidatorProtocol {
    typealias TypeToValidate = ValidationTargetType
    
    var acceptableRange: Variable<ClosedRange<Date>>
    
    /**
     */
    init(acceptableRange: ClosedRange<Date>, isRequired: Bool) {
        self.acceptableRange = Variable(acceptableRange)
        super.init()
        self.regex = nil
        self.isRequired = isRequired
    }
    
    /**
     */
    override func validate(_ input: ValidationTargetType?) -> Bool {
        guard let date = input?.date else { return !isRequired }
        return acceptableRange.value ~= date
    }
}
