//
//  OfficeKeyValueCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 17/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import IVCollectionKit

///
protocol OfficeKeyValueViewModelProtocol {
	var key: String { get }
	var value: String { get }
}

///
struct OfficeKeyValueViewModel: OfficeKeyValueViewModelProtocol {
	var key: String
	var value: String
}

final class OfficeKeyValueCollectionViewCell: UICollectionViewCell {
	private let keyLabel = UILabel()
	private let valueLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		clipsToBounds = true
		
		keyLabel.font = UIConstants.titleFont
		keyLabel.textColor = UIConstants.titleTextColor
		keyLabel.lineBreakMode = .byWordWrapping
		keyLabel.numberOfLines = 0
		keyLabel.textAlignment = .left
		addSubview(keyLabel)
		keyLabel.translatesAutoresizingMaskIntoConstraints = false
		
		valueLabel.font = UIConstants.valueFont
		valueLabel.textColor = UIConstants.valueTextColor
		valueLabel.lineBreakMode = .byWordWrapping
		valueLabel.numberOfLines = 0
		valueLabel.textAlignment = .left
		addSubview(valueLabel)
		valueLabel.translatesAutoresizingMaskIntoConstraints = false
		
		keyLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(UIConstants.horizontalSpacing)
			make.left.equalToSuperview().inset(UIConstants.horizontalSpacing)
			make.top.equalToSuperview().inset(UIConstants.topBottomInset)
		}
		
		valueLabel.snp.makeConstraints { (make) in
				make.right.equalTo(keyLabel.snp.right)
				make.left.equalTo(keyLabel.snp.left)
			make.top.equalTo(keyLabel.snp.bottom).offset(UIConstants.verticalSpacing)
			make.bottom.equalToSuperview().inset(UIConstants.topBottomInset)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

///
extension OfficeKeyValueCollectionViewCell: ConfigurableCollectionItem {
	
	static func estimatedSize(item: OfficeKeyValueViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		let maxLabelWidth = collectionViewSize.width - (UIConstants.horizontalSpacing * 2)
		let minHeight: CGFloat = 59
		let proposedHeight = UIConstants.topBottomInset * 2 + UIConstants.verticalSpacing + item.key.size(using: UIConstants.titleFont, boundingWidth: maxLabelWidth).height + item.value.size(using: UIConstants.valueFont, boundingWidth: maxLabelWidth).height
		return CGSize(width: collectionViewSize.width, height: max(minHeight, proposedHeight))
	}
	
	func configure(item: OfficeKeyValueViewModelProtocol) {
		keyLabel.text = item.key
		valueLabel.text = item.value
	}
}

///
extension OfficeKeyValueCollectionViewCell {
	///
	struct UIConstants {
		static let horizontalSpacing: CGFloat = 16
		static let topBottomInset: CGFloat = 12
		static let verticalSpacing: CGFloat = 16
		static let titleFont: UIFont = Font.regular14
		static let valueFont: UIFont = Font.medium15
		static let titleTextColor: UIColor = Color.lightBlueGray
		static let valueTextColor: UIColor = Color.black
	}
}
