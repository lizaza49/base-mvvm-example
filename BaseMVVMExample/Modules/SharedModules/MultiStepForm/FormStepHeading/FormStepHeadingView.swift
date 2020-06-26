//
//  FormStepHeadingView.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class FormStepHeadingView: UIView {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let bottomLine = UIView()
    
    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    /**
     */
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
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
            make.top.equalToSuperview()
        }
        
        subtitleLabel.apply(textStyle: UIConstants.subtitleTextStyle)
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIConstants.sideInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.labelsSpacing)
        }
        
        bottomLine.backgroundColor = UIConstants.bottomLineColor
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(UIConstants.bottomLineThickness)
        }
    }
    
    /**
     */
    func configure(with viewModel: FormStepHeadingViewModelProtocol) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
    
    /**
     */
    static func estimatedSize(for viewModel: FormStepHeadingViewModelProtocol, superviewSize: CGSize) -> CGSize {
        var height: CGFloat = 0
        let maxLabelWidth = superviewSize.width - UIConstants.sideInset * 2
        height += viewModel.title.size(using: UIConstants.titleTextStyle.font, boundingWidth: maxLabelWidth).height
        height += UIConstants.labelsSpacing
        height += viewModel.subtitle.size(using: UIConstants.subtitleTextStyle.font, boundingWidth: maxLabelWidth).height
        height += UIConstants.bottomPadding
        return CGSize(width: superviewSize.width, height: height)
    }
}

///
extension FormStepHeadingView {
    struct UIConstants {
        static let titleTextStyle = TextStyle(Color.black, Font.regular20, .left)
        static let subtitleTextStyle = TextStyle(Color.gray, Font.regular14, .left)
        
        static let sideInset: CGFloat = 16
        static let labelsSpacing: CGFloat = 1
        static let bottomLineColor = Color.shadeOfGray
        static let bottomLineThickness: CGFloat = 1
        static let bottomPadding: CGFloat = 24
    }
}
