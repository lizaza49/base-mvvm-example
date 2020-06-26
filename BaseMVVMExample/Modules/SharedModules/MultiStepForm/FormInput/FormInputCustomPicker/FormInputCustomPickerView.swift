//
//  FormInputCustomPickerView.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
class FormInputCustomPickerView: UIView {
    private var reusableDisposeBag = DisposeBag()
    private var disposeBag = DisposeBag()
    
    private let headingLabel = UILabel()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let placeholderLabel = UILabel()
    private let rightIcon = UIImageView()
    private var tapGR: UITapGestureRecognizer!
    
    private var viewModel: (() -> FormInputCustomPickerViewModelProtocol)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headingLabel.apply(textStyle: UIConstants.headingStyle)
        addSubview(headingLabel)
        headingLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview().inset(UIConstants.defaultInset)
        }
        
        containerView.layer.borderColor = UIConstants.containerBorderColor.cgColor
        containerView.layer.borderWidth = UIConstants.containerBorderWidth
        containerView.layer.cornerRadius = UIConstants.containerBorderRadius
        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(headingLabel.snp.bottom).offset(UIConstants.headingToInputspacing)
            make.left.right.equalToSuperview().inset(UIConstants.defaultInset)
            make.bottom.equalToSuperview()
        }
        
        rightIcon.image = Asset.Form.formPickerArrow.image
        containerView.addSubview(rightIcon)
        rightIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIConstants.rightIconInset)
            make.size.equalTo(UIConstants.rightIconSize)
        }
        
        titleLabel.apply(textStyle: UIConstants.titleStyle)
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(UIConstants.defaultInset)
            make.right.equalTo(rightIcon.snp.left).offset(UIConstants.rightIconInset)
        }
        
        placeholderLabel.apply(textStyle: UIConstants.placeholderTextStyle)
        containerView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(titleLabel)
        }
        
        subtitleLabel.apply(textStyle: UIConstants.subtitleStyle)
        containerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        tapGR = UITapGestureRecognizer(target: nil, action: nil)
        containerView.addGestureRecognizer(tapGR)
        tapGR.rx.event.subscribe(onNext: { _ in
            self.viewModel?().onTap?()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    
    /**
     */
    func configure(with viewModel: FormInputCustomPickerViewModelProtocol) {
        reusableDisposeBag = DisposeBag()
        self.viewModel = { viewModel }
        headingLabel.text = viewModel.heading
        titleLabel.text = viewModel.title.value
        subtitleLabel.text = viewModel.subtitle.value
        if viewModel.title.value != nil {
            placeholderLabel.text = nil
        }
        else {
            placeholderLabel.text = viewModel.placeholder
        }
        
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: reusableDisposeBag)
        viewModel.subtitle.bind(to: subtitleLabel.rx.text).disposed(by: reusableDisposeBag)
        viewModel.title
            .map { ($0 == nil) ? viewModel.placeholder : nil }
            .bind(to: placeholderLabel.rx.text)
            .disposed(by: reusableDisposeBag)
    }
    
    /**
     */
    static func estimatedSize(for viewModel: FormInputCustomPickerViewModelProtocol, superviewSize: CGSize) -> CGSize {
        var height: CGFloat = UIConstants.defaultInset
        let maxHeadingWidth = superviewSize.width - UIConstants.defaultInset * 2
        height += viewModel.heading.size(using: UIConstants.headingStyle.font, boundingWidth: maxHeadingWidth).height
        height += UIConstants.headingToInputspacing
        
        let maxInnerLabelWidth: CGFloat = maxHeadingWidth - UIConstants.defaultInset - UIConstants.rightIconInset * 2 - UIConstants.rightIconSize.width
        var containerHeight: CGFloat = UIConstants.defaultInset * 2
        if let title = viewModel.title.value {
            containerHeight += title.size(using: UIConstants.titleStyle.font, boundingWidth: maxInnerLabelWidth).height
            if let subtitle = viewModel.subtitle.value {
                containerHeight += subtitle.size(using: UIConstants.subtitleStyle.font, boundingWidth: maxInnerLabelWidth).height
            }
        }
        else {
            containerHeight += viewModel.placeholder.size(using: UIConstants.placeholderTextStyle.font, boundingWidth: maxInnerLabelWidth).height
        }
        containerHeight = max(containerHeight, UIConstants.containerMinHeight)
        return CGSize(width: superviewSize.width, height: height + containerHeight)
    }
}

///
extension FormInputCustomPickerView {
    ///
    struct UIConstants {
        static let defaultInset: CGFloat = 16
        static let containerMinHeight: CGFloat = 52
        static let headingToInputspacing: CGFloat = 8
        
        static let containerBorderColor = Color.shadeOfGray
        static let containerBorderRadius: CGFloat = 4
        static let containerBorderWidth: CGFloat = 1
        
        static let rightIconSize = CGSize(width: 24, height: 24)
        static let rightIconInset: CGFloat = 12
        
        static let headingStyle = TextStyle(Color.gray, Font.regular14, .left)
        static let titleStyle = TextStyle(Color.theDarkestGray, Font.regular15, .left)
        static let subtitleStyle = TextStyle(Color.gray, Font.regular14, .left)
        static let placeholderTextStyle = TextStyle(Color.gray, Font.regular15, .left)
    }
}
