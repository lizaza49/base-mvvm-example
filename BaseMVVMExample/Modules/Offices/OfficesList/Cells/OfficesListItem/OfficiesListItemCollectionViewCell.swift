//
//  OfficesListItemCollectionViewCell.swift
//  BaseMVVMExample
//
//  Created by Admin on 09/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class OfficesListItemCollectionViewCell: UICollectionViewCell {
	
	lazy var childOfficeVC = OfficeViewController()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = Color.white
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/**
	*/
	func addViewControllerToParent(viewController: UIViewController) {
		viewController.add(childVC: childOfficeVC, to: contentView)
	}
	
	/**
	*/
	func removeViewControllerFromParent() {
		childOfficeVC.view.removeFromSuperview()
		childOfficeVC.willMove(toParentViewController: nil)
		childOfficeVC.removeFromParentViewController()
	}
}

///
extension OfficesListItemCollectionViewCell: ConfigurableCollectionItem {
	
	/**
	*/
	static func estimatedSize(item: OfficeViewModelProtocol?, collectionViewSize: CGSize) -> CGSize {
		guard let officeViewModel = item else { return .zero }
		let height: CGFloat = officeViewModel.isExpanded.value ?
			officeViewModel.contentHeight.expanded :
			officeViewModel.contentHeight.collapsed
		return CGSize(width: collectionViewSize.width, height: height)
	}
	
	/**
	*/
	func configure(item: OfficeViewModelProtocol) {
		childOfficeVC.viewModel = item
		childOfficeVC.reload()
	}
}
