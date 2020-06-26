//
//  PolicyPurchaseSuggestionCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 27/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
fileprivate typealias Scope = Dashboard.Policies.PurchaseSuggestion

///
extension Scope {
    
    ///
    final class CollectionViewCell: UICollectionViewCell {
        
        typealias ViewModel = ViewModelProtocol
        
        ///
        private let containerView = UIView()
        private let backgroundImage = UIImageView()
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()
        private let purchaseButton = PrimaryButton()
        
        private var reusableDisposeBag = DisposeBag()
        
        /**
         */
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            containerView.backgroundColor = Color.white
            containerView.layer.cornerRadius = UIConstants.containerCornerRadius
            containerView.apply(shadowStyle: UIConstants.containerShadowStyle)
            addSubview(containerView)
            containerView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(UIConstants.contentSideInset)
                make.top.bottom.equalToSuperview()
            }
            
            backgroundImage.clipsToBounds = true
            backgroundImage.contentMode = .scaleAspectFill
            containerView.addSubview(backgroundImage)
            backgroundImage.snp.makeConstraints { (make) in
                make.right.bottom.equalToSuperview()
                make.size.equalTo(UIConstants.bgImageSize)
            }
            
            titleLabel.apply(textStyle: UIConstants.titleStyle)
            containerView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(UIConstants.contentSideInset)
                make.top.equalToSuperview().inset(UIConstants.titleTopInset)
            }
            
            subtitleLabel.apply(textStyle: UIConstants.subtitleStyle)
            containerView.addSubview(subtitleLabel)
            subtitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(UIConstants.contentSideInset)
                make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.subtitleTopInset)
            }
            
            containerView.addSubview(purchaseButton)
            purchaseButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().inset(UIConstants.buttonBottomInset)
                make.left.right.equalToSuperview().inset(UIConstants.contentSideInset)
                make.height.equalTo(UIConstants.buttonHeight)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

///
extension Scope.CollectionViewCell: ConfigurableCollectionItem {
    
    static func estimatedSize(item: ViewModel?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        let maxLabelWidth = collectionViewSize.width - UIConstants.contentSideInset * 4
        var height: CGFloat = UIConstants.titleTopInset
        height += item.title.size(using: UIConstants.titleStyle.font, boundingWidth: maxLabelWidth).height
        
        height += UIConstants.subtitleTopInset
        height += item.subtitle.size(using: UIConstants.subtitleStyle.font, boundingWidth: maxLabelWidth).height
        
        height += UIConstants.buttonTopInset
        height += UIConstants.buttonHeight
        height += UIConstants.buttonBottomInset
        
        return CGSize(width: collectionViewSize.width, height: max(height, UIConstants.minItemHeight))
    }
    
    func configure(item: ViewModel) {
        reusableDisposeBag = DisposeBag()
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        purchaseButton.setTitle(item.purchaseButtonTitle, for: .normal)
        purchaseButton.rx.tap.bind(to: item.tapAction).disposed(by: reusableDisposeBag)
        if let imageUrl = item.backgroundImageUrl {
            backgroundImage.updateImage(url: imageUrl)
        }
        else {
            backgroundImage.image = Asset.Policies.purshaseSuggestionAuto.image
        }
    }
}

extension Scope.CollectionViewCell {
    struct UIConstants {
        static let minItemHeight: CGFloat = 190
        static let containerShadowStyle = ShadowStyle(Color.black, 10, CGSize(width: 0, height: 4), 0.05)
        static let containerSideInset: CGFloat = 16
        static let containerCornerRadius: CGFloat = 8
        
        static let bgImageSize = CGSize(width: 171, height: 107)
        static let contentSideInset: CGFloat = 16
        
        static let titleStyle = TextStyle(Color.mustard, Font.regular20, .left)
        static let titleTopInset: CGFloat = 26
        
        static let subtitleStyle = TextStyle(Color.gray, Font.regular14, .left)
        static let subtitleTopInset: CGFloat = 8
        
        static let buttonHeight: CGFloat = 50
        static let buttonTopInset: CGFloat = 24
        static let buttonBottomInset: CGFloat = 24
    }
}
