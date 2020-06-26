//
//  HorizontalSnapCollectionViewFlowLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 27/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol HorizontalSnapCollectionViewLayoutDelegate: class {
    func horizontalSnapLayout(_ layout: HorizontalSnapCollectionViewLayout, willSnapToItemAt index: Int)
}

///
class HorizontalSnapCollectionViewLayout: UICollectionViewFlowLayout {
    
    private(set) var itemWidth: CGFloat?
    weak var delegate: HorizontalSnapCollectionViewLayoutDelegate?
    
    /**
     */
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return proposedContentOffset }
        let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: 0))
        let itemWidth = self.itemWidth ?? itemSize.width
        let minContentOffset: CGFloat = -collectionView.contentInset.left
        let maxContentOffset: CGFloat = itemWidth * numberOfItems
            + minimumInteritemSpacing * (numberOfItems - 1)
            - collectionView.bounds.width + collectionView.contentInset.right
        
        // create points (contentOffset.x) to magnet to
        let magnetPoints: [CGFloat] = (0 ..< Int(numberOfItems)).map {
            let proposedPoint = (itemWidth + minimumInteritemSpacing) * CGFloat($0) - minimumInteritemSpacing
            return min(max(proposedPoint, minContentOffset), maxContentOffset)
        }
        guard !magnetPoints.isEmpty else { return proposedContentOffset }
        
        // find out the closest magnet point index to the proposed one
        var closestPointIndex = magnetPoints.enumerated()
            .reduce(0, {
                let newItemSpacing = abs(magnetPoints[$1.offset] - proposedContentOffset.x)
                let partialResultSpacing = abs(magnetPoints[$0] - proposedContentOffset.x)
                guard partialResultSpacing != newItemSpacing else {
                    return velocity.x > 0 ? $1.offset : $0
                }
                return partialResultSpacing < newItemSpacing ? $0 : $1.offset
            })
        if velocity.x >= 0.5,
            proposedContentOffset.x > magnetPoints[closestPointIndex],
            closestPointIndex < magnetPoints.count - 1
            {
            closestPointIndex += 1
        }
        else if velocity.x <= -0.5,
            proposedContentOffset.x < magnetPoints[closestPointIndex],
            closestPointIndex > 0 {
            closestPointIndex -= 1
        }
        delegate?.horizontalSnapLayout(self, willSnapToItemAt: closestPointIndex)
        return CGPoint(x: magnetPoints[closestPointIndex], y: proposedContentOffset.y)
    }
}
