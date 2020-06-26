//
//  OfficePhoneCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 14/02/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import InputMask

// MARK: - ViewModel

///
protocol OfficePhoneViewModelProtocol {
	func getFormattedPhone() -> String
}

///
struct OfficePhoneViewModel: OfficePhoneViewModelProtocol {
	let phone: String
	func getFormattedPhone() -> String {
		let phoneInputMask = try? Mask(format: Constants.phoneInputMask)
		let phoneFormatted: String = phoneInputMask?.apply(toText: CaretString(string: phone)).formattedText.string ?? phone
		return phoneFormatted
	}
}

// MARK: - View

///
final class OfficePhoneCollectionViewCell: UICollectionViewCell {
	
	private let phoneLabel = UILabel()
	private let phoneIcon = UIImageView(image: Asset.Map.callBitton.image)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		clipsToBounds = true
		
		phoneIcon.contentMode = .scaleAspectFill
		addSubview(phoneIcon)
		phoneIcon.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(UIConstants.horizontalSpacing)
			make.size.equalTo(UIConstants.iconSize)
			make.top.equalToSuperview().inset(UIConstants.iconTopInset)
		}
		
		phoneLabel.font = UIConstants.phoneFont
		phoneLabel.textColor = UIConstants.phoneTextColor
		phoneLabel.textAlignment = .left
		addSubview(phoneLabel)
		phoneLabel.snp.makeConstraints { (make) in
			make.right.equalTo(phoneIcon.snp.left).offset(-UIConstants.horizontalSpacing)
			make.left.equalToSuperview().inset(UIConstants.horizontalSpacing)
			make.top.equalToSuperview().inset(UIConstants.topInset)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

///
extension OfficePhoneCollectionViewCell: ConfigurableCollectionItem {
	
	static func estimatedSize(item: OfficePhoneViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		let maxPhoneLabelWidth = collectionViewSize.width - UIConstants.iconSize.width - (UIConstants.horizontalSpacing * 3)
		let minHeight: CGFloat = 47
		let proposedHeight = UIConstants.topInset * 2 + item.getFormattedPhone().size(using: UIConstants.phoneFont, boundingWidth: maxPhoneLabelWidth).height
		return CGSize(width: collectionViewSize.width, height: max(minHeight, proposedHeight))
	}
	
	func configure(item: OfficePhoneViewModelProtocol) {
		phoneLabel.text = item.getFormattedPhone()
	}
}

///
extension OfficePhoneCollectionViewCell {
	///
	struct UIConstants {
		static let horizontalSpacing: CGFloat = 16
		static let iconSize = CGSize(width: 24, height: 24)
		static let iconTopInset: CGFloat = 11.5
		static let topInset: CGFloat = 13.5
		static let phoneFont: UIFont = Font.medium15
		static let phoneTextColor: UIColor = .black
	}
}
