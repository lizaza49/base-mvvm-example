//
//  FormInputPickerViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

///
protocol FormInputPickerViewModelProtocol {
    associatedtype Option: StringConvertible
    var options: NonEmpty<[Option]> { get }
    var selectedOptionIndex: Variable<Int?> { get }
}

///
extension FormInputPickerViewModelProtocol {
    var selectedOption: Option? {
        guard
            let index = selectedOptionIndex.value,
            (0 ..< options.count) ~= index
        else { return nil }
        return options[index]
    }
}

///
struct FormInputPickerViewModel<OptionType: StringConvertible>: FormInputPickerViewModelProtocol {
    typealias Option = OptionType
    let options: NonEmpty<[Option]>
    let selectedOptionIndex: Variable<Int?>
    
    /**
     */
    init(options: NonEmpty<[Option]>, selectedOptionIndex: Int?) {
        self.options = options
        self.selectedOptionIndex = Variable(selectedOptionIndex)
    }
}
