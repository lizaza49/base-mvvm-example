//
//  OfficeMapPickerCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 03/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import IVCollectionKit
import RxSwift

class OfficePickerCollectionViewCell: UICollectionViewCell {
	
	private let radioButton = RadioButtonControl()
	private let officeTitleLabel = UILabel()
	private let addressLineLabel = UILabel()
	private let distanceLabel = UILabel()
	private var disposeBag = DisposeBag()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		officeTitleLabel.numberOfLines = 0
		addressLineLabel.numberOfLines = 0
		officeTitleLabel.lineBreakMode = .byWordWrapping
		addressLineLabel.lineBreakMode = .byWordWrapping
		
		radioButton.isUserInteractionEnabled = false
		addSubview(radioButton)
		
		distanceLabel.textColor = UIConstants.titleColor
		distanceLabel.font = UIConstants.distanceFont
		distanceLabel.textAlignment = .right
		addSubview(distanceLabel)
		
		officeTitleLabel.textColor = UIConstants.titleColor
		officeTitleLabel.font = UIConstants.titleFont
		addSubview(officeTitleLabel)
		
		addressLineLabel.textColor = UIConstants.adressColor
		addressLineLabel.font = UIConstants.adressFont
		addSubview(addressLineLabel)
		
		radioButton.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(UIConstants.sideInset)
			make.top.equalToSuperview().inset(UIConstants.radioButtonTop)
			make.size.equalTo(RadioButtonControl.UIConstants.containerSize)
		}
		
		distanceLabel.snp.makeConstraints { (make) in
				make.top.equalTo(officeTitleLabel.snp.top)
			make.right.equalToSuperview().inset(UIConstants.horizontalSpacing)
		}
		
		officeTitleLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(UIConstants.topBottomInset)
			make.left.equalTo(radioButton.snp.right).offset(UIConstants.horizontalSpacing)
				make.right.equalTo(distanceLabel.snp.left).offset(UIConstants.horizontalSpacing)
		}
		
		addressLineLabel.snp.makeConstraints { (make) in
			make.top.equalTo(officeTitleLabel.snp.bottom).offset(UIConstants.verticalSpacing)
			make.left.equalTo(officeTitleLabel.snp.left)
			make.right.equalTo(distanceLabel.snp.left).offset(UIConstants.horizontalSpacing)
			make.bottom.equalToSuperview().inset(UIConstants.topBottomInset)
		}
	}
	
	private func updateSelectionState(_ isSelected: Bool) {
		radioButton.isSelected = isSelected
	}
}

extension OfficePickerCollectionViewCell: ConfigurableCollectionItem {
	static func estimatedSize(item: OfficeViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let item = item else { return .zero }
		var maxLabelWidth = collectionViewSize.width - (UIConstants.horizontalSpacing * 2)
		switch item.displayStyle {
		case .listItem:
			maxLabelWidth = collectionViewSize.width - (UIConstants.horizontalSpacing * 2) - (UIConstants.sideInset * 2)
		default:
			break
		}
		let proposedHeight = UIConstants.topBottomInset * 2 + UIConstants.verticalSpacing + (item.title?.size(using: UIConstants.titleFont, boundingWidth: maxLabelWidth).height ?? 0.0) + (item.adress?.size(using: UIConstants.adressFont, boundingWidth: maxLabelWidth).height ?? 0.0)
		return CGSize(width: collectionViewSize.width, height: proposedHeight)
	}
	
	func configure(item: OfficeViewModelProtocol) {
		switch item.displayStyle {
		case .popup:
			radioButton.snp.updateConstraints { (make) in
				make.left.equalToSuperview()
				make.size.equalTo(0)
			}
			radioButton.alpha = 0
		case .listItem:
			radioButton.snp.updateConstraints { (make) in
				make.left.equalToSuperview().inset(UIConstants.sideInset)
				make.size.equalTo(RadioButtonControl.UIConstants.containerSize)
			}
			radioButton.alpha = 1
		}
		officeTitleLabel.text = item.title
		addressLineLabel.text = item.adress
		distanceLabel.text = item.routeDistance.value
		
		item.isPicked.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: updateSelectionState)
			.disposed(by: disposeBag)
	}
	
	override func prepareForReuse() {
		disposeBag = DisposeBag()
	}
}

extension OfficePickerCollectionViewCell {
	struct UIConstants {
		static let horizontalSpacing: CGFloat = 16
		static let topBottomInset: CGFloat = 16
		static let sideInset: CGFloat = 16
		static let radioButtonTop: CGFloat = 24
		static let verticalSpacing: CGFloat = 4
		static let titleFont: UIFont = Font.semibold15
		static let adressFont: UIFont = Font.regular14
		static let distanceFont: UIFont = Font.regular15
		static let titleColor: UIColor = .black
		static let adressColor: UIColor = Color.lightBlueGray
	}
}
