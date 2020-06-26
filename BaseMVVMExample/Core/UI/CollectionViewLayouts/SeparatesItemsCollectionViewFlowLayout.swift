//
//  SeparatesItemsCollectionViewFlowLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
@objc protocol SeparatedItemsCollectionViewLayoutDelegate {
    func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout,
                                            shouldDecorateItemAt indexPath: IndexPath) -> Bool
    @objc optional func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout,
                                                     offsetForDecorationViewAt indexPath: IndexPath) -> CGPoint
    @objc optional func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout,
                                                           splitterFrameForItemAt indexPath: IndexPath,
                                                           ownedBy correspondingItemFrame: CGRect) -> CGRect
    @objc optional func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout,
                                                           customSplitterViewClassForItemAt indexPath: IndexPath) -> AnyClass?
    @objc optional func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout,
                                                           customSplitterOptionsForItemAt indexPath: IndexPath) -> [Any]?
}

///
enum CollectionItemsSeparationStrategy {
    case all
    case none
    case custom(decoratedItemsRanges: [Int: [Range<Int>]])
    case delegated(delegate: SeparatedItemsCollectionViewLayoutDelegate)
    case excepting(nonDecoratedItemsRanges: [Int: [Range<Int>]])
}

///
@objc class SeparatedItemsCollectionViewLayout: UICollectionViewFlowLayout {
    
    private let itemsSeparationStrategy: CollectionItemsSeparationStrategy
    private var registeredSplitterViewKinds: Set<String> = Set()
    lazy var defaultSplitterViewKind = String(describing: SplitterDecorationView.self)
    
    /**
     */
    init(itemsSeparationStrategy: CollectionItemsSeparationStrategy = .all) {
        self.itemsSeparationStrategy = itemsSeparationStrategy
        super.init()
        self.registerDecorationViewIfNeeded(SplitterDecorationView.self)
    }
    
    /**
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    private func registerDecorationViewIfNeeded(_ decorationViewClass: AnyClass) {
        let kind = String(describing: decorationViewClass)
        guard !registeredSplitterViewKinds.contains(kind) else { return }
        registeredSplitterViewKinds.insert(kind)
        self.register(decorationViewClass, forDecorationViewOfKind: kind)
    }
    
    /**
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        attrs.append(contentsOf: attrs.compactMap {
            return layoutAttributesForDecorationView(at: $0.indexPath)
        })
        return attrs
    }
    
    /**
     */
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard registeredSplitterViewKinds.contains(elementKind),
            itemShouldBeDecorated(at: indexPath),
            let correspondingItemRect = layoutAttributesForItem(at: indexPath)?.frame
            else { return nil }
        let decorationViewAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        var frame = self.frame(forDecorationViewAt: indexPath, correspondingItemFrame: correspondingItemRect)
        let offset = self.offset(forDecorationViewAt: indexPath)
        frame = frame.offsetBy(dx: offset.x, dy: offset.y)
        decorationViewAttributes.frame = frame
        if case .delegated(let delegate) = itemsSeparationStrategy,
            let options = delegate.separatedItemsCollectionViewLayout?(self, customSplitterOptionsForItemAt: indexPath) {
            decorationViewAttributes.accessibilityElements = options
        }
        return decorationViewAttributes
    }
    
    /**
     */
    func layoutAttributesForDecorationView(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if case .delegated(let delegate) = itemsSeparationStrategy,
            let customViewClass = delegate.separatedItemsCollectionViewLayout?(self, customSplitterViewClassForItemAt: indexPath) {
            registerDecorationViewIfNeeded(customViewClass)
            let kind = String(describing: customViewClass)
            return layoutAttributesForDecorationView(ofKind: kind, at: indexPath)
        }
        else {
            return layoutAttributesForDecorationView(ofKind: defaultSplitterViewKind, at: indexPath)
        }
    }
    
    /**
     */
    func itemShouldBeDecorated(at indexPath: IndexPath) -> Bool {
        switch itemsSeparationStrategy {
        case .all: return true
        case .custom(let decoratedItemsRanges):
            guard let itemRanges = decoratedItemsRanges[indexPath.section] else { return false }
            return itemRanges.reduce(false, { $0 || $1 ~= indexPath.item })
        case .delegated(let delegate):
            return delegate.separatedItemsCollectionViewLayout(self, shouldDecorateItemAt: indexPath)
        case .excepting(let nonDecoratedItemsRanges):
            guard let itemRanges = nonDecoratedItemsRanges[indexPath.section] else { return true }
            return itemRanges.reduce(false, { !($0 || $1 ~= indexPath.item) })
        case .none: return false
        }
    }
    
    /**
     */
    func invalidateVisibleDecorationItems() {
        guard let collectionView = collectionView else { return }
        let context = UICollectionViewFlowLayoutInvalidationContext()
        registeredSplitterViewKinds.forEach {
            context.invalidateDecorationElements(ofKind: $0, at: collectionView.indexPathsForVisibleItems)
        }
        invalidateLayout(with: context)
    }
    
    /**
     */
    private func offset(forDecorationViewAt indexPath: IndexPath) -> CGPoint {
        guard case .delegated(let delegate) = itemsSeparationStrategy else { return .zero }
        return delegate.separatedItemsCollectionViewLayout?(self, offsetForDecorationViewAt: indexPath) ?? .zero
    }
    
    /**
     */
    private func frame(forDecorationViewAt indexPath: IndexPath, correspondingItemFrame: CGRect) -> CGRect {
        let defaultFrame = CGRect(x: 0,
                                  y: correspondingItemFrame.maxY-1,
                                  width: correspondingItemFrame.width,
                                  height: 1)
        guard case .delegated(let delegate) = itemsSeparationStrategy else {
            return defaultFrame
        }
        return delegate.separatedItemsCollectionViewLayout?(self,
            splitterFrameForItemAt: indexPath,
            ownedBy: correspondingItemFrame) ?? defaultFrame
    }
}
