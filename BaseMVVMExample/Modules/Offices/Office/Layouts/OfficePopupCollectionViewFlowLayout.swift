//
//  OfficePopupCollectionViewFlowLayout.swift
//  BaseMVVMExample
//
//  Created by Admin on 14/02/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit
///
extension Office {
	
	///
	class PopupCollectionViewFlowLayout: SeparatedItemsCollectionViewLayout {
		
		struct UIConstants {
			static let decorationViewLeftRightInset: CGFloat = 16
			static let decorationViewHeight: CGFloat = 1
		}
		
		override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
			guard
				itemShouldBeDecorated(at: indexPath),
				let itemAttributes = layoutAttributesForItem(at: indexPath)
				else { return nil }
			let decorationViewAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: defaultSplitterViewKind, with: indexPath)
			decorationViewAttributes.frame = CGRect(x: UIConstants.decorationViewLeftRightInset,
													y: itemAttributes.frame.maxY,
													width: itemAttributes.frame.width - UIConstants.decorationViewLeftRightInset*2,
													height: UIConstants.decorationViewHeight)
			return decorationViewAttributes
		}
		
		/**
		*/
		final override func itemShouldBeDecorated(at indexPath: IndexPath) -> Bool {
			guard self.collectionView != nil else { return false }
			let isLastItem = self.isLastItem(at: indexPath)
			return !isLastItem
		}
		
		/**
		*/
		private func isLastItem(at indexPath: IndexPath) -> Bool {
			return self.indexPath(after: indexPath) == nil
		}
		
		/**
		*/
		private func indexPath(before indexPath: IndexPath) -> IndexPath? {
			guard let collectionView = self.collectionView else { return nil }
			if indexPath.item > 0 {
				return IndexPath(item: indexPath.item - 1, section: indexPath.section)
			}
			else if indexPath.section > 0 {
				let prevSection = indexPath.section - 1
				return IndexPath(item: collectionView.numberOfItems(inSection: prevSection) - 1, section: prevSection)
			}
			else {
				return nil
			}
		}
		
		/**
		*/
		private func indexPath(after indexPath: IndexPath) -> IndexPath? {
			guard let collectionView = self.collectionView else { return nil }
			let numberOfItems = collectionView.numberOfItems(inSection: indexPath.section)
			if numberOfItems > indexPath.item + 1 {
				return IndexPath(item: indexPath.item + 1, section: indexPath.section)
			}
			else if collectionView.numberOfSections > indexPath.section + 1 {
				return IndexPath(item: 0, section: indexPath.section + 1)
			}
			else {
				return nil
			}
		}
	}
	
	class OfficeListCollectionViewFlowLayout: PopupCollectionViewFlowLayout { }
}
