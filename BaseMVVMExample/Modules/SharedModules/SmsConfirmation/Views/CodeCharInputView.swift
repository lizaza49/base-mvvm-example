//
//  CodeCharInputView.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol CodeCharInputViewProtocol {
    var isEditing: Bool { get }
    var text: String? { get }
    var keyboardType: UIKeyboardType { get set }
    
    func setEditing()
    func endEditing()
    
    func setText(_ text: String)
    func appendText(_ text: String)
    
    func reset()
    func resetIfEmpty()
}

///
protocol CodeCharInputDelegate: class {
    func codeCharInputDidTapBackspace(_ inputView: CodeCharInputViewProtocol)
    func codeCharInput(_ inputView: CodeCharInputViewProtocol, didTryToEnter string: String)
}

///
class CodeCharInputView: UIView, CodeCharInputViewProtocol {
    
    var isEditing: Bool { return textField.isEditing }
    var text: String? { return textField.text }
    var keyboardType: UIKeyboardType = .numberPad
    
    private lazy var defaultSize = CGSize(width: 23, height: 45)
    private let underline = UIView()
    private let textField = UITextField()
    
    private let invisibleChar = "\u{200B}"
    
    weak var delegate: CodeCharInputDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 27, height: 45)))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        underline.backgroundColor = Color.shadeOfGray
        underline.layer.cornerRadius = 1.5
        addSubview(underline)
        underline.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(3)
        }
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        textField.apply(textStyle: UIConstants.textStyle)
        textField.tintColor = Color.cherry
        textField.delegate = self
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.bottom.equalTo(underline.snp.top).offset(-4)
            make.top.left.right.equalToSuperview()
        }
    }
    
    // MARK: - Public functions
    
    /**
     */
    func setEditing() {
        textField.keyboardType = keyboardType
        textField.becomeFirstResponder()
    }
    
    /**
     */
    func endEditing() {
        self.textField.resignFirstResponder()
    }
    
    /**
     */
    func setText(_ text: String) {
        textField.text = text
        adjustUnderline()
    }
    
    /**
     */
    func appendText(_ text: String) {
        textField.text?.append(text)
        adjustUnderline()
    }
    
    /**
     */
    func reset() {
        textField.text = invisibleChar
        adjustUnderline()
    }
    
    /**
     */
    func resetIfEmpty() {
        if (textField.text?.isEmpty ?? true) || textField.text == invisibleChar {
            reset()
        }
    }
    
    /**
     */
    private func adjustUnderline() {
        if textField.text?.isEmpty ?? true || textField.text == invisibleChar {
            underline.backgroundColor = Color.shadeOfGray
        }
        else {
            underline.backgroundColor = Color.cherry
        }
    }
}

///
extension CodeCharInputView: UITextFieldDelegate {
    
    /**
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // handle backspace
        if string.isEmpty {
            delegate?.codeCharInputDidTapBackspace(self)
            adjustUnderline()
            return false
        }
        delegate?.codeCharInput(self, didTryToEnter: string)
        return false
    }
    
    /**
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CodeCharInputView {
    struct UIConstants {
        static let textStyle = TextStyle(Color.cherry, Font.regular32, .center, 1)
    }
}
