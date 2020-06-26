//
//  DashboardPoliciesCategoryPickerCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 24/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

extension Dashboard.Policies {
    struct CategoryPicker {}
}

extension Dashboard.Policies.CategoryPicker {
    
    ///
    final class CollectionViewCell: UICollectionViewCell {
        
        private lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let cv = UICollectionView(frame: bounds, collectionViewLayout: layout)
            return cv
        }()
        private let selectionFrame = UIView()
        private lazy var director = CollectionDirector(colletionView: collectionView)
        private let section = CollectionSection()
        
        private var viewModel: (() -> DashboardPoliciesCategoryPickerViewModelProtocol)?
        
        /**
         */
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = Color.white
            setupViews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /**
         */
        private func setupViews() {
            setupCollectionView()
            
            selectionFrame.layer.cornerRadius = UIConstants.selectionFrameCornerRadius
            selectionFrame.clipsToBounds = false
            selectionFrame.apply(shadowStyle: UIConstants.selectionFrameShadow)
            selectionFrame.backgroundColor = Color.white
            selectionFrame.frame = .zero
            selectionFrame.alpha = 0
            collectionView.insertSubview(selectionFrame, at: 0)
        }
        
        
        /**
         */
        private func setupCollectionView() {
            collectionView.contentInset.left = UIConstants.collectionHorizontalContentInset
            collectionView.contentInset.right = UIConstants.collectionHorizontalContentInset
            collectionView.backgroundColor = Color.white
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.clipsToBounds = false
            addSubview(collectionView)
            collectionView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(UIConstants.collectionVerticalInsets)
            }
            director.shouldUseAutomaticViewRegistration = true
        }
        
        /**
         */
        private func configureCollectionView(with items: [PolicyCategoryViewModelProtocol], completion: (() -> Void)? = nil) {
            director.clear()
            
            section.clear()
            section.lineSpacing = Item.CollectionViewCell.UIConstants.spacing(toFill: bounds.width)
            section.append(items: items.map { itemViewModel in
                let item = CollectionItem<Item.CollectionViewCell>(item: itemViewModel)
                item.onSelect = { [weak self] indexPath in
                    self?.adjustSelectionFrame(toWrapItemAt: indexPath, animated: true)
                    self?.viewModel?().pickedCategory.value = itemViewModel
                }
                return item
            })
            
            director += section
            director.performUpdates(updates: { director.reload() }, completion: completion)
        }
        
        /**
         */
        private func adjustSelectionFrame(toWrapItemAt indexPath: IndexPath, animated: Bool = false) {
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
            collectionView.sendSubview(toBack: selectionFrame)
            let animatableAdjustments = {
                self.selectionFrame.frame = attributes.frame
                self.selectionFrame.alpha = 1
            }
            if animated {
                UIView.animate(withDuration: 0.2, animations: animatableAdjustments)
            }
            else {
                animatableAdjustments()
            }
        }
    }
}

///
extension Dashboard.Policies.CategoryPicker.CollectionViewCell: ConfigurableCollectionItem {
    
    static var reuseIdentifier: String {
        return "Dashboard.Policies.CategoryPicker.CollectionViewCell"
    }
    
    static func estimatedSize(item: DashboardPoliciesCategoryPickerViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 132)
    }
    
    func configure(item: DashboardPoliciesCategoryPickerViewModelProtocol) {
        viewModel = { item }
        configureCollectionView(with: item.categories) {
            if let selectedIndex = item.selectedItemIndex {
                let indexPath = IndexPath(item: selectedIndex, section: 0)
                self.adjustSelectionFrame(toWrapItemAt: indexPath)
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
        }
    }
}

///
fileprivate struct UIConstants {
    static let collectionVerticalInsets: CGFloat = 24
    static let collectionHorizontalContentInset: CGFloat = 16
    static let selectionFrameShadow = ShadowStyle(Color.devilGray, 11, CGSize(width: 0, height: 4), 0.3)
    static let selectionFrameCornerRadius: CGFloat = 8
}
