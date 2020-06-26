//
//  OfficeHeadingCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 03/02/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class OfficeHeadingCollectionViewCell: UICollectionViewCell {
	
	private lazy var headingView = OfficeHeadingView(frame: CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height)))
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(headingView)
		headingView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

///
extension OfficeHeadingCollectionViewCell: ConfigurableCollectionItem {
	
	static func estimatedSize(item: OfficeViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		let height = OfficeHeadingView.estimatedHeight(for: item, superviewWidth: collectionViewSize.width)
		return CGSize(width: collectionViewSize.width, height: height)
	}
	
	func configure(item: OfficeViewModelProtocol) {
		headingView.configure(with: item)
	}
}
