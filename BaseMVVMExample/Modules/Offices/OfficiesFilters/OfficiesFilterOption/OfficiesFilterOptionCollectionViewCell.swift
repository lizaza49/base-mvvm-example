//
//  OfficiesFilterOptionCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 26/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit


class OfficiesFilterOptionCollectionViewCell: UICollectionViewCell {
	private let containerView = UIView()
	private let nameLabel = UILabel()
	private let iconView = UIImageView()
	private let topLine = UIView()
	private let bottomLine = UIView()
	
	private var viewModel: OfficiesFilterOption?
	
	override var isSelected: Bool {
		didSet {
			guard isSelected != oldValue else { return }
			updateSelectionState(isSelected)
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		clipsToBounds = false
		
		addSubview(containerView)
		containerView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		iconView.contentMode = .scaleAspectFill
		containerView.addSubview(iconView)
		iconView.snp.makeConstraints { (make) in
			make.right.top.equalToSuperview().inset(UIConstants.iconInset)
			make.size.equalTo(UIConstants.iconSize)
		}
		
		nameLabel.apply(textStyle: UIConstants.nameStyle)
		containerView.addSubview(nameLabel)
		nameLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(UIConstants.nameLeftInset)
			make.top.equalToSuperview().inset(UIConstants.nameTopInset)
			make.right.equalTo(iconView.snp.left).offset(-UIConstants.nameRightInset)
		}
		
		bottomLine.backgroundColor = UIConstants.lineColor
		containerView.addSubview(bottomLine)
		bottomLine.snp.makeConstraints { (make) in
			make.bottom.left.right.equalToSuperview()
			make.height.equalTo(UIConstants.lineHeight)
		}
		
		topLine.backgroundColor = UIConstants.lineColor
		containerView.addSubview(topLine)
		topLine.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.bottom.equalTo(containerView.snp.top)
			make.height.equalTo(UIConstants.lineHeight)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/**
	*/
	private func updateSelectionState(_ isSelected: Bool) {
		guard viewModel != nil else { return }
		guard !isSelected else {
			iconView.image = Asset.Common.commonCheck.image
			return
		}
	}
}

///
extension OfficiesFilterOptionCollectionViewCell: ConfigurableCollectionItem {
	
	static func estimatedSize(item: OfficiesFilterOption?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		let maxLabelWidth: CGFloat = collectionViewSize.width - UIConstants.nameLeftInset - UIConstants.iconInset - UIConstants.iconSize.width - UIConstants.nameRightInset
		
		var height = UIConstants.nameTopInset
		height += item.enumeratedTitle.size(using: UIConstants.nameStyle.font, boundingWidth: maxLabelWidth).height
		height += UIConstants.nameBottomInset
		
		return CGSize(width: collectionViewSize.width, height: max(UIConstants.minItemHeight, height))
	}
	
	func configure(item: OfficiesFilterOption) {
		viewModel = item
		nameLabel.text = item.enumeratedTitle
		updateSelectionState(isSelected)
	}
}

///
extension OfficiesFilterOptionCollectionViewCell {
	
	///
	struct UIConstants {
		static let minItemHeight: CGFloat = 52
		
		static let nameStyle = TextStyle(Color.darkGray, Font.regular15, .left)
		static let nameLeftInset: CGFloat = 16
		static let nameTopInset: CGFloat = 17
		static let nameBottomInset: CGFloat = 15
		static let nameRightInset: CGFloat = 10
		
		static let iconFillColor = Color.iconGray
		static let iconSize = CGSize(width: 24, height: 24)
		static let iconInset: CGFloat = 14
		
		static let lineColor = Color.shadeOfGray
		static let lineHeight: CGFloat = 1
	}
}
