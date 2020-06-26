//
//  DashboardPoliciesSliderLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 25/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension Dashboard.Policies.Slider {
    
    ///
    class CollectionViewFlowLayout: HorizontalSnapCollectionViewLayout {
        
        ///
        private var allIndexPaths: [IndexPath] {
            var result: [IndexPath] = []
            guard let collectionView = self.collectionView else { return result }
            for section in 0 ..< collectionView.numberOfSections {
                for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                    result.append(IndexPath(item: item, section: section))
                }
            }
            return result
        }
        
        private let smallCardScale: CGFloat = 0.75
        private let smallCardOffsetY: CGFloat = 33
        
        /**
         */
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let indexPathsToRender = allIndexPaths.filter(itemShouldBeRendered)
            return indexPathsToRender.compactMap(layoutAttributesForItem)
        }
        
        /**
         */
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            guard
                let collectionView = self.collectionView,
                let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
            else { return nil }
            let itemWidth = collectionView.bounds.width
            let itemPositionX = attributes.frame.minX - collectionView.contentOffset.x
            if itemPositionX > 0 {
                let smallStateProgress: CGFloat = itemPositionX / itemWidth
                attributes.frame = attributes.frame.offsetBy(
                    dx: -itemWidth * CGFloat(indexPath.item) + collectionView.contentOffset.x,
                    dy: smallCardOffsetY * smallStateProgress)
                let scale = smallCardScale + (1 - smallCardScale) * (1 - smallStateProgress)
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
                attributes.alpha = max(min((2 - smallStateProgress), 1), 0)
            }
            attributes.zIndex = collectionView.numberOfItems(inSection: indexPath.section) - indexPath.item
            return attributes
        }
        
        /**
         */
        private func itemShouldBeRendered(at indexPath: IndexPath) -> Bool {
            guard
                let collectionView = self.collectionView,
                let attributes = super.layoutAttributesForItem(at: indexPath)
            else { return false }
            let itemWidth = collectionView.bounds.width
            let shouldBeRendered = attributes.frame.minX - collectionView.contentOffset.x < itemWidth * 3
            return shouldBeRendered
        }
        
        /**
         */
        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            return true
        }
    }
}
