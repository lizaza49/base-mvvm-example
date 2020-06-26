//
//  FormStepCollectionViewLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class FormStepCollectionViewLayout: SeparatedItemsCollectionViewLayout {
    
    private let hasHeader: Bool
    private let firstIndexPath = IndexPath(item: 0, section: 0)
    private var hasFirstIndexPath: Bool {
        return (collectionView?.numberOfSections ?? 0) > 0 &&
            (collectionView?.numberOfItems(inSection: 0) ?? 0) > 0
    }
    
    /**
     */
    init(hasHeader: Bool, itemsSeparationStrategy: CollectionItemsSeparationStrategy = .all) {
        self.hasHeader = hasHeader
        super.init(itemsSeparationStrategy: itemsSeparationStrategy)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        guard hasHeader, hasFirstIndexPath else { return attrs }
        attrs.removeAll(where: { $0.indexPath == firstIndexPath })
        if let firstItemAttrs = layoutAttributesForItem(at: firstIndexPath) {
            attrs.append(firstItemAttrs)
        }
        if let firstItemDecorationAttrs = layoutAttributesForDecorationView(at: firstIndexPath) {
            attrs.append(firstItemDecorationAttrs)
        }
        return attrs
    }
    
    /**
     */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let superAttrs = super.layoutAttributesForItem(at: indexPath)
        guard
            hasHeader,
            indexPath == firstIndexPath,
            let collectionView = self.collectionView
        else { return superAttrs }
        let offsetY = collectionView.contentOffset.y
        let attributes = superAttrs?.copy() as! UICollectionViewLayoutAttributes
        attributes.frame = CGRect(origin: CGPoint(x: attributes.frame.minX, y: attributes.frame.minY + offsetY),
                                  size: attributes.frame.size)
        attributes.zIndex = 100
        return attributes
    }
    
    /**
     */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
