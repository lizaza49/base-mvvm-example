//
//  ConfirmationCodeInputView.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
final class ConfirmationCodeInputView: UICollectionViewCell {
    
    // MARK: - Properties
    
    // MARK: Logic
    var viewModel: (() -> ConfirmationCodeInputViewModelProtocol)
    
    // MARK: Subviews
    private let containerView = UIView()
    private var inputViews: [CodeCharInputViewProtocol] = []
    private var overlayView = UIView()
    
    // MARK: Constants, computed dimensions, translations
    private let inputViewsSpacing: CGFloat = 16
    private let inputViewSize = CGSize(width: 27, height: 45)
    private var codeAreaWidth: CGFloat {
        let charsCount = CGFloat(viewModel().requiredLength)
        return charsCount * inputViewSize.width + (charsCount - 1) * inputViewsSpacing
    }
    
    // MARK: - Initializers
    
    init(frame: CGRect, viewModel: ConfirmationCodeInputViewModelProtocol) {
        self.viewModel = { viewModel }
        super.init(frame: CGRect(origin: .zero, size: frame.size))
        
        viewModel.resetSignal.asDriver(onErrorJustReturn: ()).drive(onNext: {
            self.reset()
        }).disposed(by: viewModel.disposeBag)
        
        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let inputViews = createInputViews(for: containerView)
        inputViews.forEach { $0.delegate = self }
        self.inputViews = inputViews
        
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlayTap)))
        containerView.addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: CGFloat(viewModel.requiredLength) * inputViewSize.width + 20, height: frame.height))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        let err = "init(coder:) has not been implemented"
        DDLogError(context: .evna, message: "class_misuse", params: [ "file" : #file, "function" : #function, "error" : err ], error: nil)
        fatalError(err)
    }
    
    // MARK: Public functions
    
    /**
     */
    func reset() {
        viewModel().code.value = []
        adjustInputSelection(shouldSetEditing: false)
    }
    
    /**
     */
    func startEditing() {
        adjustInputSelection()
    }
    
    /**
     */
    func endEditing() {
        inputViews.first(where: { $0.isEditing })?.endEditing()
    }
    
    // MARK: - Actions
    
    /**
     */
    @objc private func overlayTap() {
        self.adjustInputSelection()
    }
    
    // MARK: - Private functions
    
    /**
     */
    @discardableResult private func createInputViews(for superView: UIView) -> [CodeCharInputView] {
        var inputViews: [CodeCharInputView] = []
        let startLeftOffset: CGFloat = (self.frame.width - codeAreaWidth)/2
        for i in 0 ..< viewModel().requiredLength {
            let inputView = CodeCharInputView()
            if viewModel().code.value.count > i {
                inputView.setText(String(viewModel().code.value[i]))
            }
            superView.addSubview(inputView)
            inputView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(startLeftOffset + CGFloat(i) * (inputViewSize.width + inputViewsSpacing))
                make.top.equalToSuperview()
                make.size.equalTo(inputViewSize)
            }
            inputViews.append(inputView)
        }
        return inputViews
    }
    
    /**
     */
    private func adjustInputSelection(shouldSetEditing: Bool = true) {
        let index = viewModel().code.value.count
        if index == inputViews.count {
            if shouldSetEditing {
                inputViews[index - 1].setEditing()
            }
            return
        }
        guard index < inputViews.count else { return }
        for i in index ..< inputViews.count {
            inputViews[i].reset()
        }
        inputViews[index].resetIfEmpty()
        if shouldSetEditing {
            inputViews[index].setEditing()
        }
        else {
            inputViews.first(where: { $0.isEditing })?.endEditing()
        }
    }
}

///
extension ConfirmationCodeInputView: CodeCharInputDelegate {
    
    /**
     */
    func codeCharInputDidTapBackspace(_ inputView: CodeCharInputViewProtocol) {
        if !viewModel().code.value.isEmpty {
            viewModel().dropLast()
        }
        adjustInputSelection()
    }
    
    /**
     */
    func codeCharInput(_ inputView: CodeCharInputViewProtocol, didTryToEnter string: String) {
        let currentCount = viewModel().code.value.count
        guard currentCount < viewModel().requiredLength else { return }
        let digitsAdded = viewModel().append(string: string)
        for i in 0 ..< digitsAdded.count {
            guard currentCount + i < inputViews.count else { break }
            inputViews[currentCount + i].appendText(String(digitsAdded[i]))
        }
        
        if viewModel().isFulfilled {
            endEditing(true)
        }
        else {
            adjustInputSelection()
        }
    }
}

