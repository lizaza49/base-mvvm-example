//
//  DashboardPoliciesCategoryPickerItemCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 24/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import SDWebImage

///
extension Dashboard.Policies.CategoryPicker {
    struct Item {}
}

///
extension Dashboard.Policies.CategoryPicker.Item {
    ///
    final class CollectionViewCell: UICollectionViewCell {
       
        private let iconContainer = UIView()
        private let iconView = UIImageView()
        private let titleLabel = UILabel()
        private var viewModel: PolicyCategoryViewModelProtocol?
        
        private var didAdjustIconContainer: Bool = false
        
        override var isSelected: Bool {
            didSet {
                guard isSelected != oldValue else { return }
                updateSelectionState(animated: true)
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(iconContainer)
            iconContainer.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview().offset(UIConstants.iconOffsetY)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIConstants.iconSize)
            }
            
            iconView.contentMode = .scaleAspectFill
            iconContainer.addSubview(iconView)
            iconView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.apply(textStyle: UIConstants.labelStyle)
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(iconView.snp.bottom).offset(UIConstants.labelTopInset)
                make.left.right.equalToSuperview().inset(6)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /**
         */
        private func updateSelectionState(animated: Bool = false) {
            let animatableUpdates = {
                self.iconContainer.transform = self.isSelected ?
                    CGAffineTransform(scaleX: 1.2, y: 1.2).translatedBy(x: 0, y: 3) :
                    .identity
            }
            if animated {
                UIView.animate(withDuration: 0.3, animations: animatableUpdates)
            }
            else {
                animatableUpdates()
            }
            iconView.updateImage(
                url: viewModel?.iconUrl,
                mapper: { $0.filled(withColor: self.isSelected ? UIConstants.selectedIconColor : UIConstants.defaultIconColor) },
                animated: animated)
        }
    }
}

///
extension Dashboard.Policies.CategoryPicker.Item.CollectionViewCell: ConfigurableCollectionItem {
    
    static var reuseIdentifier: String {
        return "Dashboard.Policies.CategoryPicker.Item.CollectionViewCell"
    }
    
    static func estimatedSize(item: PolicyCategoryViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        return UIConstants.itemSize(toFit: collectionViewSize.width)
    }
    
    func configure(item: PolicyCategoryViewModelProtocol) {
        viewModel = item
        titleLabel.text = item.shortName
        updateSelectionState()
    }
}

///
extension Dashboard.Policies.CategoryPicker.Item.CollectionViewCell {
    ///
    struct UIConstants {
        private static let maxItemsInLine: CGFloat = 4
        private static let maxItemSize: CGFloat = 84
        private static let itemsSpacing: CGFloat = 6
        
        static func itemSize(toFit superviewWidth: CGFloat) -> CGSize {
            let maxSize: CGFloat = 84
            let proposedSize: CGFloat = (superviewWidth - itemsSpacing * (maxItemsInLine - 1) - 16*2) / maxItemsInLine
            let size = min(maxSize, proposedSize)
            return CGSize(width: size, height: size)
        }
        static func spacing(toFill superviewWidth: CGFloat) -> CGFloat {
            let item = itemSize(toFit: superviewWidth)
            if item.width < maxItemSize {
                return itemsSpacing
            }
            else {
                let proposedGapWidth = (superviewWidth - 16*2 - (maxItemsInLine * item.width)) / (maxItemsInLine - 1)
                return max(proposedGapWidth, itemsSpacing)
            }
        }
        static let iconSize = CGSize(width: 28, height: 28)
        static let iconOffsetY: CGFloat = -7
        static let labelTopInset: CGFloat = 7
        static let labelStyle = TextStyle(Color.gray, Font.medium10, .center, 1)
        static let selectedIconColor = Color.cherry
        static let defaultIconColor = Color.gray
    }

}
