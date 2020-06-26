//
//  MapPopupViewController.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 13/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol MapPopupViewDelegate: class {
	func mapPopupViewControllerShouldDismiss(_ viewController: MapPopupViewController)
}

///
final class MapPopupViewController: BaseViewController {
	
	var viewModel: MapPopupViewModelProtocol!
	private lazy var contentView = UIView(frame: view.bounds) // view containing popup ui elements
	private lazy var containerView = UIView(frame: contentView.bounds) // view for inserting child vc
	private let dragView = UIView()
	weak private var contentVC: UIViewController?
	private var panGR: UIPanGestureRecognizer!
	
	// MARK: Life cycle
	
	/**
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupBindings()
	}
	
	// MARK: Setup
	
	/**
	*/
	private func setupViews() {
		contentView.backgroundColor = Color.white
		contentView.apply(shadowStyle: UIConstants.contentShadowStyle)
		
		view.addSubview(contentView)
		contentView.snp.makeConstraints { (make) in
			make.left.right.bottom.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		contentView.addSubview(containerView)
		containerView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		if case OfficiesDisplayStyle.normal = viewModel.displayStyle {
			
			dragView.backgroundColor = Color.gray
			dragView.layer.cornerRadius = UIConstants.dragViewCornerRadius
			contentView.addSubview(dragView)
			
			dragView.snp.makeConstraints { (make) in
				make.top.equalToSuperview().inset(UIConstants.dragViewTop)
				make.centerX.equalToSuperview()
				make.width.equalTo(UIConstants.dragViewWidth)
				make.height.equalTo(UIConstants.dragViewHeight)
			}
		}
		
		panGR = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
		panGR.isEnabled = true
		view.addGestureRecognizer(panGR)
		
		setupBindings()
		configureContent(with: viewModel.contentModel.value)
	}
	
	private func setupBindings() {
		viewModel.contentModel
			.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: { [weak self] _ in
				guard let self = self else { return }
				self.configureContent(with: self.viewModel.contentModel.value)
			})
			.disposed(by: viewModel.disposeBag)
		
		viewModel.containerHeightUpdate
			.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: { [weak self] (update) in
				guard let self = self else { return }
				self.updateSuperviewContainerHeight(update)
			})
			.disposed(by: viewModel.disposeBag)
	}
	
	/**
	*/
	private func reloadContent(configurationAction: (() -> Void)? = nil, animated: Bool = true) {
		UIView.animate(withDuration: 0.3, animations: {
			self.containerView.alpha = 0
		}, completion: { _ in
			if let action = configurationAction {
				self.remove(childVC: self.contentVC)
				action()
			}
		})
	}
	
	/**
	*/
	private func configureContent(with contentModel: Any?) {
		var configurationAction: (() -> Void)? = nil
		if let officeModel = contentModel as? OfficeViewModelProtocol {
			configurationAction = { self.configureContent(with: officeModel) }
		}
		self.reloadContent(configurationAction: configurationAction)
	}
	
	
	/**
	*/
	private func configureContent(with officeViewModel: OfficeViewModelProtocol) {
		let officeVC = OfficeViewController()
		officeViewModel.router = OfficeRouter(viewController: officeVC)
		officeVC.viewModel = officeViewModel
		add(childVC: officeVC, to: containerView)
		UIView.animate(withDuration: 0.3, delay: 0.2, animations: {
			self.containerView.alpha = 1
		})
		contentVC = officeVC
	}
	
	/**
	*/
	private func updateSuperviewContainerHeight(_ update: MapPopupContainerHeightUpdate) {
		guard let popupContainerView = view.superview else { return }
		let height = update.height
		popupContainerView.snp.updateConstraints({ (make) in
			make.height.equalTo(height)
		})
		let animatableUpdates = {
			popupContainerView.transform = CGAffineTransform(translationX: 0, y: -height)
			popupContainerView.superview?.layoutIfNeeded()
		}
		if update.animated {
			UIView.animate(withDuration: update.animationDuration ?? 0.3, delay: 0, options: .curveEaseOut, animations: animatableUpdates, completion: { _ in
				update.completionBlock?()
			})
		}
		else {
			animatableUpdates()
			update.completionBlock?()
		}
	}
	
	// MARK: Actions
	
	/**
	*/
	@objc private func panAction(_ sender: UIPanGestureRecognizer) {
		let tY = sender.translation(in: view).y
		let magnetPoints: [CGFloat] = MapPopupState.ordered.map { viewModel.containerHeight(for: $0) }
		let initialState = viewModel.state.value
		let initialHeight: CGFloat = viewModel.currentStateHeight
		var proposedHeight = initialHeight - tY
		// Fit bounds
		proposedHeight = max(magnetPoints.reduce(1000.0, { min($0, $1) }), proposedHeight) // ensure greater than 0
		// Add bounce effect
		let bounceOverpan = proposedHeight - magnetPoints.last!
		if bounceOverpan > 0 {
			proposedHeight = magnetPoints.last! + 2 * pow(bounceOverpan, UIConstants.bounceOverpanPow)
		}
		
		switch sender.state {
		case .began, .changed:
			viewModel.containerHeightUpdate.value = MapPopupContainerHeightUpdate(
				height: proposedHeight, animated: false)
			break
			
		case .ended:
			guard magnetPoints.count > 1 else {
				update(state: initialState, with: proposedHeight)
				return
			}
			let vY = sender.velocity(in: view).y
			var targetInterval = (magnetPoints.count - 1 ... magnetPoints.count - 1)
			guard magnetPoints.count > 1 else { return }
			for i in 0 ..< magnetPoints.count - 1 {
				if (magnetPoints[i] ..< magnetPoints[i + 1]) ~= proposedHeight {
					targetInterval = (i ... i + 1)
					break
				}
			}
			guard targetInterval.upperBound > targetInterval.lowerBound else {
				update(state: MapPopupState(rawValue: targetInterval.upperBound) ?? initialState, with: proposedHeight)
				return
			}
			var targetState: MapPopupState!
			if (-UIConstants.vYConstant ... UIConstants.vYConstant) ~= vY {
				let spaceToLowerBound = abs(proposedHeight - magnetPoints[targetInterval.lowerBound])
				let spaceToUpperBound = abs(proposedHeight - magnetPoints[targetInterval.upperBound])
				targetState = (spaceToUpperBound >= spaceToLowerBound) ?
					MapPopupState(rawValue: targetInterval.lowerBound)! :
					MapPopupState(rawValue: targetInterval.upperBound)!
			}
			else {
				targetState = vY > UIConstants.vYConstant ?
					MapPopupState(rawValue: targetInterval.lowerBound)! :
					MapPopupState(rawValue: targetInterval.upperBound)!
			}
			update(state: targetState, with: proposedHeight)
			break
			
		case .cancelled, .failed:
			update(state: initialState, with: proposedHeight)
			break
			
		default:
			break
		}
	}
	
	/**
	*/
	private func snapAnimationDuration(for state: MapPopupState, currentContainerHeight: CGFloat) -> Double {
		let absoluteSnapLength = abs(currentContainerHeight - viewModel.containerHeight(for: state))
		return max(Double(absoluteSnapLength / viewModel.containerHeight(for: .collapsed) * UIConstants.containerHeightScaleFactor), UIConstants.minContainerHeight)
	}
	
	/**
	*/
	private func update(state: MapPopupState, with proposedContainerHeight: CGFloat) {
		let containerHeight = viewModel.containerHeight(for: state)
		viewModel.state.value = state
		panGR.isEnabled = false
		viewModel.containerHeightUpdate.value = MapPopupContainerHeightUpdate(height: containerHeight, animationDuration: snapAnimationDuration(for: state, currentContainerHeight: proposedContainerHeight)) { [weak self] in
			guard let self = self else { return }
			self.panGR.isEnabled = true
			if state == .hidden {
				self.viewModel.delegate?.mapPopupViewControllerShouldDismiss(self)
			}
		}
	}
}

fileprivate struct UIConstants {
	static let contentShadowStyle = ShadowStyle(Color.black.withAlphaComponent(0.2), 12, CGSize(width: 0, height: -4), 0.2)
	static let dragViewCornerRadius: CGFloat = 1.5
	static let dragViewTop: CGFloat = 9.0
	static let dragViewWidth: CGFloat = 30.0
	static let dragViewHeight: CGFloat = 3.0
	static let containerHeightScaleFactor: CGFloat = 0.45
	static let minContainerHeight: Double = 0.15
	static let bounceOverpanPow: CGFloat = 0.667
	static let vYConstant: CGFloat = 200
}
