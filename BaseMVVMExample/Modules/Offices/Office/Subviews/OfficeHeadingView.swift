//
//  OfficeHeadingView.swift
//  BaseMVVMExample
//
//  Created by Admin on 01/02/2019.
//  Copyright © 2019 Zeno Inc. All rights reserved.
//

import Foundation
import UIKit

///
final class OfficeHeadingView: UIView, ConfigurableOfficeView {
	typealias ViewModel = OfficeViewModelProtocol
	
	// MARK: Properties
	
	private var viewModel: (() -> ViewModel)?
	
	private let routeButton = OfficeRouteButton()
	
	private let officeTitleLabel = UILabel()
	private let addressLineLabel = UILabel()
	
	
	// MARK: Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	init() {
		super.init(frame: .zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		let topInset = UIConstants.topInset(for: .popup(displayStyle: .normal))
		officeTitleLabel.numberOfLines = 0
		addressLineLabel.numberOfLines = 0
		officeTitleLabel.lineBreakMode = .byWordWrapping
		addressLineLabel.lineBreakMode = .byWordWrapping
		
		routeButton.addTarget(self, action: #selector(toRoute), for: .touchUpInside)
		addSubview(routeButton)
		routeButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(topInset)
			make.right.equalToSuperview()
			make.size.equalTo(UIConstants.RouteButton.size)
		}
		
		officeTitleLabel.textColor = UIConstants.Title.textColor
		officeTitleLabel.font = UIConstants.Title.font
		addSubview(officeTitleLabel)
		officeTitleLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(UIConstants.Title.titleLeftInset)
			make.right.equalTo(routeButton.snp.left).inset(UIConstants.Title.titleRightInset)
				make.top.equalToSuperview().inset(topInset)
		}
		
		addressLineLabel.textColor = UIConstants.Adress.textColor
		addressLineLabel.font = UIConstants.Adress.font
		addSubview(addressLineLabel)
		addressLineLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(UIConstants.Adress.titleLeftInset)
			make.right.equalTo(routeButton.snp.left).inset(UIConstants.Adress.titleRightInset)
			make.top.equalTo(officeTitleLabel.snp.bottom).offset(UIConstants.verticalSpacing)
				make.bottom.equalToSuperview().inset(topInset)
		}
	}
	
	// MARK: ConfigurableOfficeView protocol stuff
	
	/**
	*/
	static func estimatedHeight(for viewModel: ViewModel,
								superviewWidth: CGFloat = UIScreen.main.bounds.width) -> CGFloat {
		var height: CGFloat = UIConstants.topInset(for: viewModel.displayStyle)
		
		// Title line height
		let maxTitleLineHeight = superviewWidth - UIConstants.Title.titleRightInset - UIConstants.horizontalInset
		
		height += viewModel.title?.size(using: UIConstants.Title.font, boundingWidth: maxTitleLineHeight).height ?? 0
		height += UIConstants.verticalSpacing
		
		// Address line height
		let maxAddressLineHeight = superviewWidth - UIConstants.Adress.titleRightInset - UIConstants.horizontalInset
		height += viewModel.adress?.size(using: UIConstants.Adress.font, boundingWidth: maxAddressLineHeight).height ?? 0
		height += UIConstants.verticalSpacing
		
		height += UIConstants.outlinedItemVerticalInset
		return height
	}
	
	/**
	*/
	func configure(with viewModel: ViewModel) {
		self.viewModel = { viewModel }
		routeButton.setTitle(viewModel.routeDistance.value)
		
		let topInset = UIConstants.topInset(for: viewModel.displayStyle)
		
		addressLineLabel.text = viewModel.adress
		officeTitleLabel.text = viewModel.title
		
		routeButton.snp.updateConstraints { (make) in
			make.top.equalToSuperview().inset(UIConstants.routeButtonTopInset(for: viewModel.displayStyle))
		}
	}
	
	// MARK: Actions
	
	/**
	*/
	@objc private func toRoute() {
		viewModel?().viewDidRequestRouteToOffice()
	}
}

///
extension OfficeHeadingView {
	///
	struct UIConstants {
		static func topInset(for displayStyle: OfficeViewDisplayStyle) -> CGFloat {
			switch displayStyle {
			case .popup(displayStyle: _):
				return 27
			case .listItem(displayStyle: _):
				return outlinedItemVerticalInset
			}
		}
		static func routeButtonTopInset(for displayStyle: OfficeViewDisplayStyle) -> CGFloat {
			switch displayStyle {
			case .popup(displayStyle: _):
				return 27
			case .listItem(displayStyle: _):
				return 8
			}
		}
		static let horizontalInset: CGFloat = 16
		static let verticalSpacing: CGFloat = 8
		
		struct RouteButton {
			static let size = CGSize(width: 56, height: 42)
			static let iconSize: CGFloat = 24
			static var iconBottomInset: CGFloat { return size.height - iconSize }
		}
		
		struct Title {
			static let font: UIFont = Font.semibold15
			static let textColor: UIColor = .black
			static let titleLeftInset: CGFloat = 16.0
			static let titleRightInset: CGFloat = 36.0
		}
		
		struct Adress {
			static let font: UIFont = Font.regular14
			static let textColor: UIColor = Color.lightBlueGray
			static let titleLeftInset: CGFloat = 16.0
			static let titleRightInset: CGFloat = 10.0
		}
		
		static let outlinedItemVerticalInset: CGFloat = 12.5
	}
}
