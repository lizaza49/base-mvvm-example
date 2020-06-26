//
//  OfficeRouteButton.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/03/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import UIKit

///
fileprivate typealias UIConstants = OfficeHeadingView.UIConstants.RouteButton

///
class OfficeRouteButton: UIControl {
	
	private let imageView = UIImageView(image: Asset.Map.createPath.image)
	private let titleLabel = UILabel()
	private var tapGR: UITapGestureRecognizer!
	
	/**
	*/
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	init() {
		super.init(frame: CGRect(origin: .zero, size: UIConstants.size))
		setup()
	}
	
	/**
	*/
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/**
	*/
	private func setup() {
		isUserInteractionEnabled = true
		
		imageView.isUserInteractionEnabled = false
		imageView.contentMode = .scaleAspectFill
		addSubview(imageView)
		imageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.height.equalTo(UIConstants.iconSize)
		}
		
		titleLabel.isUserInteractionEnabled = false
		titleLabel.textColor = Color.cherry
		titleLabel.textAlignment = .right
		titleLabel.font = Font.medium12
		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .byClipping
		titleLabel.adjustsFontSizeToFitWidth = true
		addSubview(titleLabel)
		titleLabel.snp.makeConstraints { (make) in
			make.right.equalTo(imageView.snp.right)
			make.left.equalToSuperview()
			make.top.equalTo(imageView.snp.bottom).offset(4)
		}
		
		tapGR = UITapGestureRecognizer(target: self, action: #selector(tapAction))
		addGestureRecognizer(tapGR)
	}
	
	/**
	*/
	@objc private func tapAction() {
		sendActions(for: .touchUpInside)
	}
	
	/**
	*/
	func setTitle(_ title: String?) {
		titleLabel.text = title
	}
}
