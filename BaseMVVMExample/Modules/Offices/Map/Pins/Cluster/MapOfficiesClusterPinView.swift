//
//  MapOfficiesClusterPinView.swift
//  BaseMVVMExample
//
//  Created by Admin on 02/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit

///
class MapOfficiesClusterPinView: UIView {
	
	private let backgroundIcon = UIImageView(image: Asset.Map.pinCluster.image)
	private let countLabel = UILabel()
	var viewModel: MapOfficiesPinClusterViewModelProtocol
	
	/**
	*/
	init(viewModel: MapOfficiesPinClusterViewModelProtocol) {
		self.viewModel = viewModel
		super.init(frame: CGRect(origin: .zero, size: UIConstants.size))
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		backgroundColor = .clear
		
		backgroundIcon.contentMode = .scaleAspectFit
		// Frame is needed for making a snapshot right after initialization
		backgroundIcon.frame = CGRect(x: (UIConstants.size.width - UIConstants.circleIconWidth)/2, y: 0,
									  width: UIConstants.circleIconWidth, height: UIConstants.size.height)
		addSubview(backgroundIcon)
		backgroundIcon.snp.makeConstraints { (make) in
			make.top.bottom.centerX.equalToSuperview()
			make.width.equalTo(UIConstants.circleIconWidth)
		}
		
		countLabel.textAlignment = .center
		countLabel.textColor = Color.cherry
		countLabel.font = Font.regular12
		countLabel.numberOfLines = 1
		countLabel.lineBreakMode = .byClipping
		countLabel.text = viewModel.count > 9 ? "9+" : String(viewModel.count)
		let labelSize = countLabel.sizeThatFits(.zero)
		// Frame is needed for making a snapshot right after initialization
		countLabel.frame = CGRect(
			origin: CGPoint(x: 8, y: frame.midY - labelSize.height/2),
			size: CGSize(width: UIConstants.size.width - 8*2, height: labelSize.height))
		addSubview(countLabel)
		countLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.left.right.equalToSuperview().inset(8)
		}
	}
}

///
extension MapOfficiesClusterPinView {
	
	///
	struct UIConstants {
		static let size = CGSize(width: 56, height: 56)
		static let circleIconWidth: CGFloat = 45
	}
}
