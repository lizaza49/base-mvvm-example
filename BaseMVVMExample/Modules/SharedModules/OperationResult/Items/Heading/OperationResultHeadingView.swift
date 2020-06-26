//
//  OperationResultHeadingView.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class OperationResultHeadingView: UIView {
    
    private let resultIcon = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Color.cherry
        
        resultIcon.contentMode = .scaleAspectFill
        addSubview(resultIcon)
        resultIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(UIConstants.topInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(UIConstants.iconSize)
        }
        
        titleLabel.apply(textStyle: UIConstants.titleStyle)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(resultIcon.snp.bottom).offset(UIConstants.titleTopInset)
            make.width.lessThanOrEqualTo(UIConstants.labelsMaxWidth)
        }
        
        subtitleLabel.apply(textStyle: UIConstants.subtitleStyle)
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.subtitleTopInset)
            make.width.lessThanOrEqualTo(UIConstants.labelsMaxWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    func configure(with viewModel: OperationResultHeadingViewModelProtocol) {
        switch viewModel.type {
        case .success:
            resultIcon.image = Asset.OperationResult.operationResultSuccess.image
            break
        case .failure:
            resultIcon.image = Asset.OperationResult.operationResultFailure.image
            break
        }
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
    
    /**
     */
    static func estimatedSize(for viewModel: OperationResultHeadingViewModelProtocol, superviewSize: CGSize) -> CGSize {
        var height: CGFloat = UIConstants.topInset
        height += UIConstants.iconSize.height
        height += UIConstants.titleTopInset
        height += viewModel.title.size(using: UIConstants.titleStyle.font, boundingWidth: UIConstants.labelsMaxWidth).height
        height += UIConstants.subtitleTopInset
        height += viewModel.subtitle.size(using: UIConstants.subtitleStyle.font, boundingWidth: UIConstants.labelsMaxWidth).height
        height += UIConstants.bottomInset
        return CGSize(width: superviewSize.width, height: height)
    }
}

extension OperationResultHeadingView {
    struct UIConstants {
        static let topInset: CGFloat = 136
        static let iconSize = CGSize(width: 82, height: 82)
        static let titleTopInset: CGFloat = 23
        static let subtitleTopInset: CGFloat = 16
        static let bottomInset: CGFloat = 64
        static let labelsMaxWidth: CGFloat = 240
        
        static let titleStyle = TextStyle(Color.white, Font.heavy20, .center)
        static let subtitleStyle = TextStyle(Color.white, Font.medium14, .center)
    }
}
