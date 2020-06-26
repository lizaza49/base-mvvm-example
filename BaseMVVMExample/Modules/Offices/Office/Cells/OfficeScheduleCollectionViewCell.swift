//
//  OfficeScheduleCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 17/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import IVCollectionKit

///
protocol OfficeScheduleViewModelProtocol {
	var schedule: String { get }
}

///
struct OfficeScheduleViewModel: OfficeScheduleViewModelProtocol {
	var schedule: String
}

final class OfficeScheduleCollectionViewCell: UICollectionViewCell {
	private let scheduleLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		clipsToBounds = true
		
		scheduleLabel.font = UIConstants.scheduleFont
		scheduleLabel.textColor = UIConstants.textColor
		scheduleLabel.lineBreakMode = .byWordWrapping
		scheduleLabel.numberOfLines = 0
		scheduleLabel.textAlignment = .left
		addSubview(scheduleLabel)
		scheduleLabel.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(UIConstants.horizontalSpacing)
			make.left.equalToSuperview().inset(UIConstants.horizontalSpacing)
			make.top.equalToSuperview().inset(UIConstants.topBottomInset)
			make.bottom.equalToSuperview().inset(UIConstants.topBottomInset)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

///
extension OfficeScheduleCollectionViewCell: ConfigurableCollectionItem {
	
	static func estimatedSize(item: OfficeScheduleViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		let maxLabelWidth = collectionViewSize.width - (UIConstants.horizontalSpacing * 2)
		let minHeight: CGFloat = 57
		let proposedHeight = UIConstants.topBottomInset * 2 + minHeight
			//item.schedule.size(using: UIConstants.scheduleFont, boundingWidth: maxLabelWidth).height
		return CGSize(width: collectionViewSize.width, height: max(minHeight, proposedHeight))
	}
	
	func configure(item: OfficeScheduleViewModelProtocol) {
		scheduleLabel.text = item.schedule
	}
}

///
extension OfficeScheduleCollectionViewCell {
	///
	struct UIConstants {
		static let horizontalSpacing: CGFloat = 16
		static let topBottomInset: CGFloat = 18
		static let scheduleFont: UIFont = Font.regular14
		static let textColor: UIColor = Color.lightBlueGray
	}
}
