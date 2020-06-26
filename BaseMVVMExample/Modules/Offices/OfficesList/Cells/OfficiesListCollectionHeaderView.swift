//
//  OfficesListCollectionHeaderView.swift
//  BaseMVVMExample
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class OfficesListCollectionHeaderView: UICollectionReusableView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

///
extension OfficesListCollectionHeaderView: ConfigurableCollectionItem {
	static func estimatedSize(item: OfficiesListSectionType?, collectionViewSize: CGSize) -> CGSize {
		return CGSize(width: collectionViewSize.width, height: UIConstants.height)
	}
	
	func configure(item: OfficiesListSectionType) {
		//
	}
}

///
extension OfficesListCollectionHeaderView {
	struct UIConstants {
		static let height: CGFloat = 8.0
	}
}
