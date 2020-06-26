//
//  FormInputRadiobuttonCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 02/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
final class FormInputRadiobuttonCollectionViewCell: UICollectionViewCell {
    
    private var viewModel: (() -> FormInputRadiobuttonOptionViewModelProtocol)?
    
    private let radioButton = RadioButtonControl()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let disposeBag = DisposeBag()
    private var reusableDisposeBag = DisposeBag()
    
    private let tapGR = UITapGestureRecognizer(target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        radioButton.isUserInteractionEnabled = false
        addSubview(radioButton)
        radioButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.radioButtonLeftInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(RadioButtonControl.UIConstants.containerSize)
        }
        
        titleLabel.apply(textStyle: UIConstants.titleStyle)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.titleLeftInset)
            make.right.equalToSuperview().inset(UIConstants.inset)
            make.top.equalToSuperview().inset(UIConstants.inset)
        }
        
        subtitleLabel.apply(textStyle: UIConstants.subtitleStyle)
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.subtitleTopInset)
            make.right.equalToSuperview().inset(UIConstants.inset)
        }
        
        tapGR.cancelsTouchesInView = true
        addGestureRecognizer(tapGR)
        tapGR.rx.event.bind(onNext: { _ in
            self.viewModel?().toggleSelectionState()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension FormInputRadiobuttonCollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: FormInputRadiobuttonOptionViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        let maxLabelWidth = collectionViewSize.width - UIConstants.titleLeftInset - UIConstants.inset
        var height: CGFloat = UIConstants.inset * 2
        height += item.title.size(using: UIConstants.titleStyle.font, boundingWidth: maxLabelWidth).height
        height += UIConstants.subtitleTopInset
        if let subtitle = item.subtitle {
            height += subtitle.size(using: UIConstants.subtitleStyle.font, boundingWidth: maxLabelWidth).height
        }
        return CGSize(width: collectionViewSize.width, height: height)
    }
    
    func configure(item: FormInputRadiobuttonOptionViewModelProtocol) {
        viewModel = { item }
        reusableDisposeBag = DisposeBag()
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        item.isSelected.bind(to: radioButton.rx.isSelected).disposed(by: reusableDisposeBag)
    }
}

///
extension FormInputRadiobuttonCollectionViewCell {
    ///
    struct UIConstants {
        static let titleStyle = TextStyle(Color.black, Font.regular15, .left)
        static let subtitleStyle = TextStyle(Color.gray, Font.regular14, .left)
        static let radioButtonLeftInset: CGFloat = inset - (RadioButtonControl.UIConstants.containerSize.width - RadioButtonControl.UIConstants.iconSize.width)/2
        static let inset: CGFloat = 16
        static let subtitleTopInset: CGFloat = 1
        static let titleLeftInset: CGFloat = inset * 2 + RadioButtonControl.UIConstants.iconSize.width
    }
}
