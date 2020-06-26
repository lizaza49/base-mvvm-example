//
//  FormInputViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import InputMask


///
enum FormInputType<InputData: StringConvertible> {
	enum FormInputArrowType {
		case none, down, right
	}
    case keyboard(initialValue: InputData?)
    case picker(viewModel: FormInputPickerViewModel<InputData>)
    case date(viewModel: FormInputDatePickerViewModelProtocol, formatter: DateFormatter)
    case imagePicker(initialImage: InputData?)
    case customPicker(initialValue: InputData?, arrowType: FormInputArrowType)
}

///
protocol AbstractFormInputKey {
    var rawValue: String { get }
    init?(rawValue: String)
}

/// Defined to wrap generic-constrainted FormInputViewModelProtocol
/// in order to use it as an array element
protocol AbstractFormInputViewModelProtocol: class {
    var key: AbstractFormInputKey? { get }
    var inputValidationSignal: PublishSubject<Bool> { get }
    var inputHasChangedSignal: BehaviorSubject<Void?> { get }
    var isResponder: Bool { get }
    var prev: AbstractFormInputViewModelProtocol? { get set }
    var next: AbstractFormInputViewModelProtocol? { get set }
    var becomeResponderSignal: PublishSubject<Bool> { get }
    var inputIsValid: Bool { get }
}

///
extension AbstractFormInputViewModelProtocol {
    func performValidation() {
        inputValidationSignal.onNext(inputIsValid)
    }
}

///
extension Array where Element == AbstractFormInputViewModelProtocol {
    
    /**
     */
    func chain() {
        let itemsToChain = self.filter { $0.isResponder }
        guard itemsToChain.count > 1 else { return }
        for i in 0 ..< itemsToChain.count {
            if i > 0 {
                itemsToChain[i].prev = itemsToChain[i-1]
            }
            if i < itemsToChain.count - 1 {
                itemsToChain[i].next = itemsToChain[i+1]
            }
        }
    }
    
    /**
     */
    func chained() -> [Element] {
        chain()
        return self
    }
}

///
protocol FormInputViewModelProtocol: AbstractFormInputViewModelProtocol {
    associatedtype InputData: StringConvertible
    var title: String? { get }
    var placeholder: String? { get }
    var note: String? { get }
    var maskDescriptor: FormInputMaskDescriptor? { get }
    var type: FormInputType<InputData> { get }
    var value: Variable<InputData?> { get }
    var validator: InputValidator<InputData>? { get }
    var validationDataMapper: InputValidationDataMapper<InputData>? { get }
    var options: [FormInputViewOption] { get }
    var onTap: (() -> Void)? { get }
    
    var widthFactor: Float { get }
    var customInsets: FormInputViewModel<InputData>.CustomInsets? { get }
    
    var disposeBag: DisposeBag { get }
}

///
class FormInputViewModel<InputDataType: StringConvertible>: FormInputViewModelProtocol {
    typealias InputData = InputDataType
    
    ///
    struct CustomInsets {
        var left, right: Float
    }
    
    let key: AbstractFormInputKey?
    let title: String?
    let placeholder: String?
    let note: String?
    let maskDescriptor: FormInputMaskDescriptor?
    let type: FormInputType<InputData>
    let value: Variable<InputData?>
    let validator: InputValidator<InputData>?
    let validationDataMapper: InputValidationDataMapper<InputData>?
    let options: [FormInputViewOption]
    let onTap: (() -> Void)?
    
    let widthFactor: Float
    let customInsets: CustomInsets?
    
    weak var next: AbstractFormInputViewModelProtocol?
    weak var prev: AbstractFormInputViewModelProtocol?
    let becomeResponderSignal = PublishSubject<Bool>()
    var inputIsValid: Bool {
        return self.validator?.validate(self.validationDataMapper?.map(value.value) ?? value.value) ?? true
    }
    var isResponder: Bool { return true }
    
    let inputHasChangedSignal = BehaviorSubject<Void?>(value: nil)
    let inputValidationSignal = PublishSubject<Bool>()
    let disposeBag = DisposeBag()
    
    /**
     */
    init(key: AbstractFormInputKey? = nil,
         title: String?,
         placeholder: String? = nil,
         note: String? = nil,
         maskDescriptor: FormInputMaskDescriptor? = nil,
         type: FormInputType<InputData>,
         validator: InputValidator<InputData>? = nil,
         validationDataMapper: InputValidationDataMapper<InputData>? = nil,
         options: [FormInputViewOption] = [],
         onTap: (() -> Void)? = nil,
         widthFactor: Float = 1.0,
         customInsets: CustomInsets? = nil) {
        self.key = key
        self.title = title
        self.placeholder = placeholder
        self.note = note
        self.maskDescriptor = maskDescriptor
        self.type = type
        self.validator = validator
        self.validationDataMapper = validationDataMapper
        self.options = options
        self.onTap = onTap
        self.widthFactor = widthFactor
        self.customInsets = customInsets
        
        switch type {
        case .keyboard(let initialValue), .customPicker(let initialValue, _):
            self.value = Variable(initialValue)
            break
        
        case .picker(let viewModel):
            self.value = Variable(viewModel.selectedOption)
            viewModel.selectedOptionIndex.asObservable()
                .map { _ in viewModel.selectedOption }
                .bind(to: value)
                .disposed(by: disposeBag)
            break
        
        case .date(let viewModel, let formatter):
            let initialDate = viewModel.selectedDate.value
            self.value = Variable(DateWrapper(date: initialDate, formatter: formatter) as? InputDataType)
            viewModel.selectedDate.asObservable()
                .map { date in DateWrapper(date: date, formatter: formatter) as? InputDataType }
                .bind(to: value)
                .disposed(by: disposeBag)
            break
            
        case .imagePicker(let initialImage):
            self.value = Variable(initialImage)
            break
        }
        
        setupBindings()
    }
    
    /**
     */
    private func setupBindings() {
        value.asObservable()
            .map { self.validator?.validate(self.validationDataMapper?.map($0) ?? $0) ?? true }
            .bind(to: inputValidationSignal)
            .disposed(by: disposeBag)
        
        value.asObservable()
            .map { _ in return () }
            .bind(to: inputHasChangedSignal)
            .disposed(by: disposeBag)
    }
}
