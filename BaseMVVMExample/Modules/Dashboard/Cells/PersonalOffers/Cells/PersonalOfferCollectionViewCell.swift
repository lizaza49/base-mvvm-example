//
//  PersonalOfferCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 14/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import SDWebImage

///
final class PersonalOfferCollectionViewCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let offerLabel = UILabel()
    
    private let tagContainerView = UIView()
    private let tagLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.layer.cornerRadius = 8
        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview()
            make.right.equalToSuperview().inset(UIConstants.containerRightInset)
        }
        
        titleLabel.apply(textStyle: UIConstants.titleTextStyle)
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.labelsLeftInset)
            make.right.equalToSuperview().inset(UIConstants.labelsRightInset)
            make.top.equalToSuperview().inset(UIConstants.titleTopInset)
        }
        
        subtitleLabel.apply(textStyle: UIConstants.subtitleTextStyle)
        subtitleLabel.alpha = 0.5
        containerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.titleSubtitleSpacing)
        }
        
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(UIConstants.imageLeftInset)
            make.size.equalTo(UIConstants.imageSize)
            make.bottom.equalToSuperview()
        }
        
        offerLabel.apply(textStyle: UIConstants.offerTextStyle)
        containerView.addSubview(offerLabel)
        offerLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(UIConstants.offerRightInset)
            make.bottom.equalToSuperview().inset(UIConstants.offerBottomInset)
        }
        
        tagLabel.lineBreakMode = .byClipping
        tagLabel.apply(textStyle: UIConstants.tagTextStyle)
        containerView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(4)
            make.top.equalToSuperview().inset(21)
            make.width.equalTo(0)
        }
        
        tagContainerView.layer.cornerRadius = 4
        tagContainerView.layer.shadowOffset = CGSize(width: -3, height: 6)
        tagContainerView.layer.shadowRadius = 7
        tagContainerView.layer.shadowOpacity = 0.2
        containerView.insertSubview(tagContainerView, belowSubview: tagLabel)
        tagContainerView.snp.makeConstraints { (make) in
            make.left.equalTo(tagLabel).offset(-12)
            make.right.equalTo(tagLabel).offset(12)
            make.top.equalTo(tagLabel).offset(-5)
            make.bottom.equalTo(tagLabel).offset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///
extension PersonalOfferCollectionViewCell: ConfigurableCollectionItem {
    
    /**
     */
    static func estimatedSize(item: PersonalOfferViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: UIConstants.cellWidth, height: collectionViewSize.height)
    }

    /**
     */
    func configure(item: PersonalOfferViewModelProtocol) {
        containerView.backgroundColor = Color.make(hex: item.backgroundColorHex)
        
        if item.hasShadow {
            containerView.apply(shadowStyle: ShadowStyle(Color.black, 10, CGSize(width: 0, height: 4), 0.05))
        }
        else {
            containerView.removeShadow()
        }
        
        // labels
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        offerLabel.text = item.offer
        
        // image
        imageView.image = nil
        SDWebImageManager.shared().loadImage(with: item.imageURL, options: [], progress: nil) { [weak self] (image, _, _, _, _, url) in
            guard url == item.imageURL else { return }
            self?.imageView.image = image
        }
        
        // tag
        let tagColor = Color.make(hex: item.tagColor)
        tagContainerView.backgroundColor = tagColor
        tagContainerView.layer.shadowColor = tagColor?.cgColor
        tagLabel.text = item.tag
        let tagLabelWidth = item.tag.size(using: UIConstants.tagTextStyle.font, boundingWidth: containerView.frame.width).width
        tagLabel.snp.updateConstraints { (make) in
            make.width.equalTo(tagLabelWidth)
        }
    }
}

extension PersonalOfferCollectionViewCell {
    struct UIConstants {
        static let cellWidth: CGFloat = 298
        
        static let titleTextStyle = TextStyle(Color.white, Font.regular18, .left, 2)
        static let subtitleTextStyle = TextStyle(Color.white, Font.regular14, .left, 2)
        static let offerTextStyle = TextStyle(Color.white, Font.thin48, .right, 1)
        static let tagTextStyle = TextStyle(Color.white, Font.regular15, .right, 1)
        
        static let containerRightInset = 8
        static let labelsLeftInset: CGFloat = 16
        static let labelsRightInset: CGFloat = 22
        
        static let titleTopInset: CGFloat = 62
        static let titleSubtitleSpacing: CGFloat = 8
        static let offerRightInset: CGFloat = 18
        static let offerBottomInset: CGFloat = 13
        
        static let imageSize = CGSize(width: 129, height: 87)
        static let imageLeftInset: CGFloat = 16
    }
}
