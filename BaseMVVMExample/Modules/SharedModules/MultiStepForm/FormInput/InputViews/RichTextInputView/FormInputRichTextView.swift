//
//  FormInputRichTextView.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 06/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class FormInputRichTextView: UIView {
	
	var viewModel: (() -> FormInputRichTextViewModelProtocol)?
	
	private let titleLabel = UILabel()
	private let placeholderLabel = UILabel()
	private let inputContainerView = UIView()
	private let textView = UITextView()
	private var maskDelegate: NotifyingMaskedTextViewDelegate?
	
	private var state = BehaviorRelay<InputFieldViewState>(value: .default)
	private let disposeBag = DisposeBag()
	
	var isEditing: Bool {
		return textView.isFirstResponder
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupBindings()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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
		
		textView.delegate = self
		textView.tintColor = Color.cherry
		textView.apply(textStyle: UIConstants.inputTextStyle)
		inputContainerView.addSubview(textView)
		textView.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview().inset(UIConstants.sideInset)
			make.top.bottom.equalToSuperview()
		}
	}
	
	private func setupBindings() {
		state.asDriver().drive(onNext: update).disposed(by: disposeBag)
	}
	
	private func update(state: InputFieldViewState) {
		switch state {
		case .default:
			inputContainerView.layer.borderColor = UIConstants.inputBorderColor.cgColor
			textView.textColor = UIConstants.inputTextStyle.color
		case .invalid:
			inputContainerView.layer.borderColor = UIConstants.invalidInputColor.cgColor
			textView.textColor = UIConstants.invalidInputColor
		}
	}
	
	func configure(with viewModel: FormInputRichTextViewModelProtocol) {
		self.viewModel = { viewModel }
		//reusableDisposeBag = DisposeBag()
		titleLabel.text = viewModel.title
		
		// Set mask
		if let maskDescriptor = viewModel.maskDescriptor {
			maskDelegate = NotifyingMaskedTextViewDelegate(descriptor: maskDescriptor)
			maskDelegate?.editingListener = self
			textView.delegate = maskDelegate
		}
		else {
			maskDelegate = nil
			textView.delegate = self
		}
	}
	
	static func estimatedSize(for viewModel: FormInputRichTextViewModelProtocol, superviewSize: CGSize) -> CGSize {
		var height: CGFloat = UIConstants.topInset
		let maxLabelWidth = superviewSize.width - UIConstants.sideInset * 2
		if let title = viewModel.title {
			height += title.size(using: UIConstants.titleTextStyle.font, boundingWidth: maxLabelWidth).height + 2
			height += UIConstants.titleToInputspacing
		}
		height += UIConstants.inputHeight
		
		
		var width = superviewSize.width
		let roundFactor: CGFloat = 1.0 / UIScreen.main.scale
		width = (width / roundFactor).rounded(.down) * roundFactor
		
		return CGSize(width: width, height: height)
	}
}

extension FormInputRichTextView: UITextViewDelegate {
	
}

extension FormInputRichTextView: NotifyingMaskedTextViewDelegateListener {
	func onEditingChanged(inTextView: UITextView) {
		<#code#>
	}
	
	func textViewDidBeginEditing(_ inTextView: UITextView) {
		<#code#>
	}
	
	
}

extension FormInputRichTextView {
	struct UIConstants {
		static let topInset: CGFloat = 16
		static let titleToInputspacing: CGFloat = 8
		static let sideInset: CGFloat = 16
		static let inputHeight: CGFloat = 104
		
		static let inputBorderColor = Color.shadeOfGray
		static let inputBorderRadius: CGFloat = 4
		static let inputBorderWidth: CGFloat = 1
		static let invalidInputColor = Color.cherry
		
		static let titleTextStyle = TextStyle(Color.gray, Font.regular14, .left)
		static let placeholderTextStyle = TextStyle(Color.gray, Font.regular15, .left)
		static let inputTextStyle = TextStyle(Color.black, Font.regular15, .left)
	}
}

