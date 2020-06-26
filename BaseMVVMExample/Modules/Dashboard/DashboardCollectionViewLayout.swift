//
//  DashboardCollectionViewLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 15/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class DashboardCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var shouldAdjustVeryFirstCell: Bool {
        return collectionView?.cellForItem(at: firstItemIndexPath) is PromoBannerCollectionViewCell
    }
    private lazy var firstItemIndexPath = IndexPath(item: 0, section: 0)
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        guard
            indexPath == firstItemIndexPath,
            shouldAdjustVeryFirstCell,
            let contentOffsetY = collectionView?.contentOffset.y
        else {
            return attributes
        }
        let itemHeightIncrement = contentOffsetY < 0 ? abs(contentOffsetY) : 0
        let maxIncrement = abs(PromoBannerCollectionViewCell.UIConstants.cellMinMaxHeightDiff)
        let adjustedIncrement = min(itemHeightIncrement, maxIncrement)
        attributes.frame = CGRect(x: attributes.frame.minX,
                                  y: attributes.frame.minY - itemHeightIncrement,
                                  width: attributes.frame.width,
                                  height: attributes.frame.height + adjustedIncrement)
        return attributes
    }
    
    /**
     */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return shouldAdjustVeryFirstCell
    }

    /**
     */
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        guard let collectionView = self.collectionView else {
            return UICollectionViewFlowLayoutInvalidationContext()
        }
        let oldContentOffset = collectionView.contentOffset.y
        let newContentOffset = newBounds.minY
        // Ensure old and new have different signs
        guard oldContentOffset.sign != newContentOffset.sign || newContentOffset < 0 else {
            return UICollectionViewFlowLayoutInvalidationContext()
        }
        let context = UICollectionViewFlowLayoutInvalidationContext()
        context.invalidateItems(at: [ firstItemIndexPath ])
        return context
    }
}
