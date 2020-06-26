//
//  DashboardPoliciesSliderCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 25/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
extension Dashboard.Policies.Slider {
    ///
    final class CollectionViewCell: UICollectionViewCell {
        
        typealias ViewModel = ViewModelProtocol
        
        private lazy var collectionView: UICollectionView = {
            let layout = CollectionViewFlowLayout()
            layout.itemSize = CGSize(width: bounds.width, height: UIConstants.collectionDefaultHeight)
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            layout.delegate = self
            let cv = UICollectionView(frame: bounds, collectionViewLayout: layout)
            return cv
        }()
        private lazy var director = CollectionDirector(colletionView: collectionView)
        private let policiesSection = CollectionSection()
        
        private lazy var pageControl = UIPageControl()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /**
         */
        private func setupViews() {
            setupCollectionView()
            
            pageControl.pageIndicatorTintColor = UIConstants.pageControlColor
            pageControl.currentPageIndicatorTintColor = UIConstants.pageControlSelectedColor
            addSubview(pageControl)
            pageControl.snp.makeConstraints { (make) in
                make.top.equalTo(collectionView.snp.bottom).offset(UIConstants.pageControlTopInset)
                make.centerX.equalToSuperview()
                make.height.equalTo(UIConstants.pageControlHeight)
            }
        }
        
        /**
         */
        private func setupCollectionView() {
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.alwaysBounceHorizontal = true
            collectionView.backgroundColor = .clear
            collectionView.clipsToBounds = false
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            addSubview(collectionView)
            collectionView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().inset(UIConstants.collectionTopInset)
                make.height.equalTo(UIConstants.collectionDefaultHeight)
            }
            director.shouldUseAutomaticViewRegistration = true
        }
        
        /**
         */
        private func configureCollectionView(with viewModel: ViewModel) {
            defer {
                director += policiesSection
                director.performUpdates(updates: { director.reload() })
            }
            director.clear()
            policiesSection.clear()
            
            guard !viewModel.policies.value.isEmpty else {
                if let purchaseSuggestion = viewModel.purchaseSuggestion {
                    collectionView.isUserInteractionEnabled = true
                    policiesSection += CollectionItem<Dashboard.Policies.PurchaseSuggestion.CollectionViewCell>(item: purchaseSuggestion)
                }
                else {
                    collectionView.isUserInteractionEnabled = false
                    policiesSection += CollectionItem<PolicyItemCollectionViewCell>(item: PolicyItemViewModel.dummy)
                }
                return
            }
            collectionView.isUserInteractionEnabled = true
            policiesSection += viewModel.policies.value.map { itemViewModel in
                let item = CollectionItem<PolicyItemCollectionViewCell>(item: itemViewModel)
                item.onSelect = { [weak viewModel] _ in
                    viewModel?.tapAction.onNext(itemViewModel)
                }
                return item
            }
        }
    }
}

///
extension Dashboard.Policies.Slider.CollectionViewCell: ConfigurableCollectionItem {
    
    /**
     */
    static func estimatedSize(item: ViewModel?, collectionViewSize: CGSize) -> CGSize {
        guard let item = item else { return .zero }
        guard !item.policies.value.isEmpty else {
            let purchaseSuggestionHeight = Dashboard.Policies.PurchaseSuggestion.CollectionViewCell.estimatedSize(
                item: Dashboard.Policies.PurchaseSuggestion.ViewModel.default,
                collectionViewSize: collectionViewSize).height
            return CGSize(
                width: collectionViewSize.width,
                height: UIConstants.cellHeight(withPurchaseSuggestionHeight: purchaseSuggestionHeight))
        }
        let maxItemHeight = item.policies.value
            .map { PolicyItemCollectionViewCell.estimatedSize(
                item: $0,
                collectionViewSize: collectionViewSize).height }
            .reduce(PolicyItemCollectionViewCell.UIConstants.cellHeight, { max($0, $1) })
        return CGSize(
            width: collectionViewSize.width,
            height: UIConstants.cellHeight(with: maxItemHeight))
    }
    
    /**
     */
    func configure(item: ViewModel) {
        configureCollectionView(with: item)
        let maxItemHeight = item.policies.value
            .map { PolicyItemCollectionViewCell.estimatedSize(item: $0, collectionViewSize: self.bounds.size).height }
            .reduce(PolicyItemCollectionViewCell.UIConstants.cellHeight, { max($0, $1) })
        collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(maxItemHeight)
        }
        pageControl.numberOfPages = item.policies.value.count
        pageControl.currentPage = item.selectedItemIndex ?? 0
    }
}

///
extension Dashboard.Policies.Slider.CollectionViewCell {
    ///
    struct UIConstants {
        static let collectionDefaultHeight: CGFloat = 190
        static let collectionTopInset: CGFloat = 16
        static let collectionBottomInset: CGFloat = 58
        static func cellHeight(with maxPolicyItemHeight: CGFloat) -> CGFloat {
            return maxPolicyItemHeight + collectionTopInset + collectionBottomInset
        }
        static func cellHeight(withPurchaseSuggestionHeight purchaseSuggestionHeight: CGFloat) -> CGFloat {
            return purchaseSuggestionHeight + collectionTopInset + collectionBottomInset
                - pageControlHeight - pageControlTopInset
        }
        
        static let pageControlHeight: CGFloat = 6
        static let pageControlTopInset: CGFloat = 22
        static let pageControlColor = Color.lightGray
        static let pageControlSelectedColor = Color.mustard
    }
}

///
extension Dashboard.Policies.Slider.CollectionViewCell: HorizontalSnapCollectionViewLayoutDelegate {
    
    /**
     */
    func horizontalSnapLayout(_ layout: HorizontalSnapCollectionViewLayout, willSnapToItemAt index: Int) {
        pageControl.currentPage = index
    }
}

