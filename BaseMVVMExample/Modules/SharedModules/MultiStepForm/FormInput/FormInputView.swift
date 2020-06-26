//
//  FormInputView.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import InputMask

///
class FormInputView<BaseFormViewModelType: FormInputViewModelProtocol>: UIView, UITextFieldDelegate, FormInputViewProtocol {
    var viewModel: (() -> BaseFormViewModelType)?
    
    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let inputContainerView = UIView()
    private let textField = UITextField()
    private let innerNoteLabel = UILabel()
    private let rightIcon = UIImageView()
    private var tapGR: UITapGestureRecognizer?
    private var maskDelegate: NotifyingMaskedTextFieldDelegate?
    private var state = BehaviorRelay<InputFieldViewState>(value: .default)
    
    private let disposeBag = DisposeBag()
    private var reusableDisposeBag = DisposeBag()
    
    var isEditing: Bool {
        return textField.isEditing
    }

    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupViews() {
        titleLabel.apply(textStyle: UIConstants.titleTextStyle)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(UIConstants.topInset)
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
        }
        
        inputContainerView.layer.borderColor = UIConstants.inputBorderColor.cgColor
        inputContainerView.layer.borderWidth = UIConstants.inputBorderWidth
        inputContainerView.layer.cornerRadius = UIConstants.inputBorderRadius
        addSubview(inputContainerView)
        inputContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.titleToInputspacing)
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
            make.height.equalTo(UIConstants.inputHeight)
        }
        
        textField.delegate = self
        textField.tintColor = Color.cherry
        textField.apply(textStyle: UIConstants.inputTextStyle)
        inputContainerView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
            make.top.bottom.equalToSuperview()
        }
        
        inputContainerView.addSubview(rightIcon)
        rightIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIConstants.rightIconInset)
            make.size.equalTo(UIConstants.rightIconSize)
        }
        
        noteLabel.apply(textStyle: UIConstants.noteTextStyle)
        addSubview(noteLabel)
        noteLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
            make.top.equalTo(inputContainerView.snp.bottom).offset(UIConstants.noteTopInset)
        }
        
        tapGR = UITapGestureRecognizer(target: self, action: #selector(containerTap))
        inputContainerView.addGestureRecognizer(tapGR!)
    }
    
    /**
     */
    private func setupBindings() {
        state.asDriver().drive(onNext: update).disposed(by: disposeBag)
    }
    
    /**
     */
    private func createToolbar(hasNextField: Bool) -> FormInputViewToolbar {
        let toolbar = FormInputViewToolbar()
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: hasNextField ? L10n.Common.Common.Button.next : L10n.Common.Common.Button.done,
            style: .plain,
            target: self,
            action: #selector(toolbarDoneTap))
        let controlStates: [UIControl.State] = [.normal, .highlighted]
        controlStates.forEach {
            doneButton.setTitleTextAttributes([.font: UIConstants.inputAccessotyButtonFont], for: $0)
        }
        toolbar.setItems([spacing, doneButton], animated: false)
        return toolbar
    }
    
    /**
     */
    private func apply(options: [FormInputViewOption]) {
        for option in options {
            if case .autocapitalization(let type) = option {
                textField.autocapitalizationType = type
            }
            else {
                textField.autocapitalizationType = .none
            }
            if case .keyboardType(let type) = option {
                textField.keyboardType = type
            }
            else {
                textField.keyboardType = .default
            }
        }
    }
    
    /**
     */
    private func update(state: InputFieldViewState) {
        switch state {
        case .default:
            inputContainerView.layer.borderColor = UIConstants.inputBorderColor.cgColor
            textField.textColor = UIConstants.inputTextStyle.color
        case .invalid:
            inputContainerView.layer.borderColor = UIConstants.invalidInputColor.cgColor
            textField.textColor = UIConstants.invalidInputColor
        }
    }
    
    // MARK: Actions

    /**
     */
    @objc private func containerTap() {
        viewModel?().onTap?()
    }
    
    /**
     */
    @objc private func toolbarDoneTap() {
        if let next = viewModel?().next {
            next.becomeResponderSignal.onNext(true)
        }
        else {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: Configuration
    
    /**
     */
    func configure(with viewModel: BaseFormViewModelType) {
        self.viewModel = { viewModel }
        reusableDisposeBag = DisposeBag()
        titleLabel.text = viewModel.title
        noteLabel.text = viewModel.note
        if let placeholder = viewModel.placeholder {
            let placeholderColor = UIConstants.placeholderTextStyle.color
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [ .font: UIConstants.placeholderTextStyle.font,
                              .foregroundColor: placeholderColor])
        }
        else {
            textField.attributedPlaceholder = nil
        }
        
        // Set textField input
        switch viewModel.type {
        case .keyboard(let initialValue):
            textField.returnKeyType = viewModel.next != nil ? .next : .done
            textField.inputView = nil
            textField.text = (viewModel.value.value ?? initialValue)?.asString
            textField.tintColor = Color.cherry
            rightIcon.image = nil
            textField.rx.text
                .skip(1)
                .map { $0 as? BaseFormViewModelType.InputData }
                .bind(to: viewModel.value)
                .disposed(by: reusableDisposeBag)
            break
        case .picker(let pickerViewModel):
            let pickerView = FormInputPickerView<FormInputPickerViewModel<BaseFormViewModelType.InputData>>()
            pickerView.viewModel = pickerViewModel
            textField.text = pickerViewModel.selectedOption?.asString
            textField.inputView = pickerView
            textField.inputAccessoryView = createToolbar(hasNextField: viewModel.next != nil)
            textField.tintColor = .clear
            rightIcon.image = Asset.Form.formPickerArrow.image
            pickerViewModel.selectedOptionIndex.asObservable()
                .map { _ in pickerViewModel.selectedOption?.asString }
                .bind(to: textField.rx.text)
                .disposed(by: reusableDisposeBag)
            break
        
        case .date(let datePickerViewModel, let formatter):
            let datePickerView = FormInputDatePickerView()
            datePickerView.viewModel = datePickerViewModel
            if let selectedDate = datePickerViewModel.selectedDate.value {
                textField.text = formatter.string(from: selectedDate)
            }
            else {
                textField.text = nil
            }
            textField.inputView = datePickerView
            textField.inputAccessoryView = createToolbar(hasNextField: viewModel.next != nil)
            textField.tintColor = .clear
            rightIcon.image = nil
            datePickerViewModel.selectedDate.asObservable()
                .map { $0 == nil ? nil : formatter.string(from: $0!) }
                .bind(to: textField.rx.text)
                .disposed(by: reusableDisposeBag)
            break
            
        case .imagePicker:
            rightIcon.image = Asset.Form.formAttach.image
            viewModel.value.asObservable()
                .map { $0?.asString }
                .bind(to: textField.rx.text)
                .disposed(by: reusableDisposeBag)
            break
            
        case .customPicker(let initialValue, let arrowType):
            textField.inputView = nil
            textField.text = (viewModel.value.value ?? initialValue)?.asString
            textField.tintColor = Color.cherry
			switch arrowType {
			case .none:
				rightIcon.image = nil
			case .down:
				rightIcon.image = Asset.Form.formPickerArrow.image
			case .right:
				rightIcon.image = Asset.Common.commonDisclosureArrow.image
			}
            viewModel.value.asObservable()
                .map { $0?.asString }
                .bind(to: textField.rx.text)
                .disposed(by: reusableDisposeBag)
        }
        
        // Manage tap GR
        switch viewModel.type {
        case .imagePicker(_), .customPicker(_):
            tapGR?.isEnabled = true
            textField.isUserInteractionEnabled = false
        default:
            tapGR?.isEnabled = false
            textField.isUserInteractionEnabled = true
        }
        
        // Set mask
        if let maskDescriptor = viewModel.maskDescriptor {
            maskDelegate = NotifyingMaskedTextFieldDelegate(descriptor: maskDescriptor)
            maskDelegate?.editingListener = self
            textField.delegate = maskDelegate
        }
        else {
            maskDelegate = nil
            textField.delegate = self
        }
        
        // Setup bindings
        viewModel.becomeResponderSignal
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { shouldBecome in
                switch viewModel.type {
                case .keyboard, .date, .picker:
                    if shouldBecome {
                        self.textField.becomeFirstResponder()
                    }
                    else {
                        self.textField.resignFirstResponder()
                    }
                    break
                case .customPicker, .imagePicker:
                    guard shouldBecome else { return }
                    viewModel.prev?.becomeResponderSignal.onNext(false)
                    viewModel.onTap?()
                    break
                }
            })
            .disposed(by: reusableDisposeBag)
        viewModel.inputValidationSignal
            .asDriver(onErrorJustReturn: false)
            .map { self.textField.isEditing ? true : $0 }
            .map { (isValid) -> InputFieldViewState in
                return isValid ? .default : .invalid }
            .drive(onNext: (state.accept))
            .disposed(by: reusableDisposeBag)
        
        apply(options: viewModel.options)
        
        // Adjust UI
        let viewstoUpdateInsets = [titleLabel, inputContainerView, noteLabel]
        if let customInsets = viewModel.customInsets {
            viewstoUpdateInsets.forEach {
                $0.snp.updateConstraints({ (make) in
                    make.left.equalToSuperview().inset(CGFloat(customInsets.left))
                    make.right.equalToSuperview().inset(CGFloat(customInsets.right))
                })
            }
        }
        else {
            viewstoUpdateInsets.forEach {
                $0.snp.updateConstraints({ (make) in
                    make.left.right.equalToSuperview().inset(UIConstants.sideInset)
                })
            }
        }
    }
    
    /**
     */
    static func estimatedSize(for viewModel: BaseFormViewModelType, superviewSize: CGSize) -> CGSize {
        var height: CGFloat = UIConstants.topInset
        let maxLabelWidth = superviewSize.width - UIConstants.sideInset * 2
        if let title = viewModel.title {
            height += title.size(using: UIConstants.titleTextStyle.font, boundingWidth: maxLabelWidth).height + 2
            height += UIConstants.titleToInputspacing
        }
		height += UIConstants.inputHeight
        if let note = viewModel.note {
            height += UIConstants.noteTopInset
            height += note.size(using: UIConstants.noteTextStyle.font, boundingWidth: maxLabelWidth).height
        }
		
        
        var width = superviewSize.width * CGFloat(viewModel.widthFactor)
        let roundFactor: CGFloat = 1.0 / UIScreen.main.scale
        width = (width / roundFactor).rounded(.down) * roundFactor
        
        return CGSize(width: width, height: height)
    }
 
    // MARK: UITextFieldDelegate conformance
    
    /**
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let next = viewModel?().next {
            next.becomeResponderSignal.onNext(true)
            return false
        }
        return true
    }
    
    /**
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let viewModel = viewModel?() else { return }
        switch viewModel.type {
        case .keyboard:
            textField.returnKeyType = viewModel.next != nil ? .next : .done
            break
        case .date:
            textField.inputAccessoryView = createToolbar(hasNextField: viewModel.next != nil)
            break
        case .picker:
            textField.inputAccessoryView = createToolbar(hasNextField: viewModel.next != nil)
            UIView.animate(withDuration: 0.2, animations: {
                self.rightIcon.transform = CGAffineTransform(rotationAngle: .pi)
            })
            break
        default:
            break
        }
    }
    
    /**
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard case .picker? = viewModel?().type else { return }
        UIView.animate(withDuration: 0.2, animations: {
            self.rightIcon.transform = .identity
        })
    }
}

///
extension FormInputView: NotifyingMaskedTextFieldDelegateListener {
    
    /**
     */
    func onEditingChanged(inTextField: UITextField) {
        viewModel?().value.value = inTextField.text as? BaseFormViewModelType.InputData
    }
}

///
enum FormInputViewOption {
    case autocapitalization(type: UITextAutocapitalizationType)
    case keyboardType(type: UIKeyboardType)
}

///
fileprivate struct UIConstants {
    static let topInset: CGFloat = 16
    static let titleToInputspacing: CGFloat = 8
    static let sideInset: CGFloat = 16
    static let inputHeight: CGFloat = 52
    
    static let inputBorderColor = Color.shadeOfGray
    static let inputBorderRadius: CGFloat = 4
    static let inputBorderWidth: CGFloat = 1
    static let invalidInputColor = Color.cherry
    
    static let rightIconSize = CGSize(width: 24, height: 24)
    static let rightIconInset: CGFloat = 12
    
    static let noteTopInset: CGFloat = 11
    
    static let titleTextStyle = TextStyle(Color.gray, Font.regular14, .left)
    static let noteTextStyle = TextStyle(Color.gray, Font.regular12, .left)
    static let placeholderTextStyle = TextStyle(Color.gray, Font.regular15, .left)
    static let inputTextStyle = TextStyle(Color.black, Font.regular15, .left)
    static let inputAccessotyButtonFont = Font.semibold17
}
