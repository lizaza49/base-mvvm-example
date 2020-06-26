//
//  FormInputDatePickerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
enum FormInputDatePickerMode: Int {
    case time = 0, date, dateTime
}

///
protocol FormInputDatePickerViewModelProtocol {
    var selectedDate: Variable<Date?> { get }
    var range: Variable<ClosedRange<Date>> { get }
    var mode: FormInputDatePickerMode { get }
    var disposeBag: DisposeBag { get }
}

///
class FormInputDatePickerViewModel: FormInputDatePickerViewModelProtocol {
    let selectedDate: Variable<Date?>
    let range: Variable<ClosedRange<Date>>
    let mode: FormInputDatePickerMode
    let disposeBag = DisposeBag()
    
    /**
     */
    init(selectedDate: Date? = nil, range: ClosedRange<Date>, mode: FormInputDatePickerMode) {
        self.selectedDate = Variable(selectedDate)
        self.range = Variable(range)
        self.mode = mode
    }
}
