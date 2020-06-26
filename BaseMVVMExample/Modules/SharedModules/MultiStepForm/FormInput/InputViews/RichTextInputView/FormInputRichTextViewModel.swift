//
//  FormInputRichTextViewModel.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 06/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift

protocol FormInputRichTextViewModelProtocol: AbstractFormInputViewModelProtocol {
	var title: String? { get }
	var placeholder: String? { get }
	var maskDescriptor: FormInputMaskDescriptor? { get }
}

class FormInputRichTextViewModel: FormInputRichTextViewModelProtocol {
	var title: String?
	var placeholder: String?
	var key: AbstractFormInputKey?
	var prev: AbstractFormInputViewModelProtocol?
	var next: AbstractFormInputViewModelProtocol?
	let becomeResponderSignal = PublishSubject<Bool>()
	var inputIsValid: Bool { return true }
	var isResponder: Bool { return true }
	var maskDescriptor: FormInputMaskDescriptor?
	
	let inputHasChangedSignal = BehaviorSubject<Void?>(value: nil)
	let inputValidationSignal = PublishSubject<Bool>()
	let disposeBag = DisposeBag()
	
	
	init(key: AbstractFormInputKey? = nil,
		 title: String?,
		 placeholder: String? = nil,
		 maskDescriptor: FormInputMaskDescriptor? = nil,
		 isRequired: Bool) {
		self.key = key
		self.title = title
		self.placeholder = placeholder
		self.maskDescriptor = maskDescriptor
		inputValidationSignal.onNext(inputIsValid)
		setupBindings()
	}
	
	private func setupBindings() {
		
	}
}
