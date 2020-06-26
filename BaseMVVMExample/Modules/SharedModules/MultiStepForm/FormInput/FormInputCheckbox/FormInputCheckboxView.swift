//
//  FormInputCheckboxView.swift
//  BaseMVVMExample
//
//  Created by Admin on 22/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
class FormInputCheckboxView: UIView {
    
    private let checkbox = CheckboxControl()
    private let textLabel = UILabel()
    
    private var disposeBag = DisposeBag()
    
    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(checkbox)
        checkbox.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.checkboxleftInset)
            make.top.equalToSuperview().inset(UIConstants.minCheckboxTopInset)
            make.size.equalTo(CheckboxControl.UIConstants.containerSize)
        }
        
        textLabel.apply(textStyle: UIConstants.textStyle)
        addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(checkbox.snp.right).offset(UIConstants.textLeftInset)
            make.top.right.equalToSuperview().inset(UIConstants.textDefaultInset)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkbox.snp.updateConstraints { (make) in
            make.top.equalToSuperview().inset(bounds.height > UIConstants.minHeight ? UIConstants.maxCheckboxTopInset : UIConstants.minCheckboxTopInset)
        }
    }
    
    /**
     */
    func configure(with viewModel: FormInputCheckboxViewModelProtocol) {
        disposeBag = DisposeBag()
        checkbox.isSelected = viewModel.checked.value
        textLabel.text = viewModel.text
        checkbox.rx.controlEvent(.valueChanged)
            .asObservable()
            .map { self.checkbox.isSelected }
            .bind(to: viewModel.checked)
            .disposed(by: disposeBag)
    }
    
    /**
     */
    static func estimatedSize(for viewModel: FormInputCheckboxViewModelProtocol, superviewSize: CGSize) -> CGSize {
        let checkboxSize = CheckboxControl.UIConstants.containerSize
        let maxTextWidth: CGFloat = superviewSize.width - UIConstants.checkboxleftInset - checkboxSize.width - UIConstants.textLeftInset
        var height = UIConstants.textDefaultInset * 2
        height += viewModel.text.size(using: UIConstants.textStyle.font, boundingWidth: maxTextWidth).height
        return CGSize(width: superviewSize.width, height: max(UIConstants.minHeight, height))
    }
}

extension FormInputCheckboxView {
    struct UIConstants {
        static let checkboxleftInset: CGFloat = 13
        static let minCheckboxTopInset: CGFloat = 14
        static let maxCheckboxTopInset: CGFloat = 23
        static let textLeftInset: CGFloat = 13
        static let textDefaultInset: CGFloat = 19
        
        static let minHeight: CGFloat = 56
        
        static let textStyle = TextStyle(Color.black, Font.regular15, .left)
    }
}
