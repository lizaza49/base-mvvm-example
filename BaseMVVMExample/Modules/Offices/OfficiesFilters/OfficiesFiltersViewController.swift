//
//  OfficiesFiltersViewController.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 26/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
final class OfficiesFiltersViewController: BaseViewController {
	
	var viewModel: OfficiesFiltersViewModelProtocol!
	
	private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
	private lazy var director = CollectionDirector(colletionView: collectionView)
	
	private let dimmingView = UIView()
	private let section = CollectionSection()
	
	// MARK: Life cycle
	
	/**
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		configureCollectionView()
	}
	
	/**
	*/
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		collectionView.transform = CGAffineTransform(translationX: 0, y: -collectionView.bounds.height)
		dimmingView.alpha = 0
		let animatableUpdates = {
			self.dimmingView.alpha = 0.3
			self.collectionView.transform = .identity
		}
		UIView.animate(withDuration: 0.3, animations: animatableUpdates)
	}
	
	/**
	*/
	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		viewModel.viewWillDismiss.onNext(())
		let animatableUpdates = {
			self.dimmingView.alpha = 0
			self.collectionView.transform = CGAffineTransform(translationX: 0, y: -self.collectionView.bounds.height)
		}
		if flag {
			UIView.animate(withDuration: 0.3, animations: animatableUpdates, completion: { _ in
				self.removeFromParent()
				completion?()
			})
		}
		else {
			animatableUpdates()
			removeFromParent()
			completion?()
		}
	}
	
	// MARK: Setup
	
	/**
	*/
	private func setupViews() {
		view.backgroundColor = .clear
		
		dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDimmingViewTap)))
		dimmingView.backgroundColor = Color.black
		view.addSubview(dimmingView)
		dimmingView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		setupCollectionView()
	}
	
	/**
	*/
	private func setupCollectionView() {
		collectionView.backgroundColor = Color.white
		view.addSubview(collectionView)
		
		let collectionHeight: CGFloat = viewModel.filterOptions
			.map {
				OfficiesFilterOptionCollectionViewCell.estimatedSize(item: $0, collectionViewSize: view.bounds.size).height }
			.reduce(0, { $0 + $1 })
		collectionView.snp.makeConstraints { (make) in
			make.left.right.top.equalToSuperview()
			make.height.equalTo(collectionHeight)
		}
	}
	
	// MARK: Configuration
	
	/**
	*/
	private func configureCollectionView() {
		director.clear()
		section.clear()
		section.append(items: viewModel.filterOptions
			.map { optionViewModel in
				let item = CollectionItem<OfficiesFilterOptionCollectionViewCell>(item: optionViewModel)
				item.onSelect = { [unowned self] indexPath in
					self.viewModel.selectedOption.onNext(optionViewModel)
					self.dismiss(animated: true)
				}
				return item
		})
		director += section
		director.performUpdates(updates: {
			director.reload()
		}, completion: {
			guard let selectedIndex = self.viewModel.selectedOptionIndex else { return }
			self.collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0),
										   animated: false,
										   scrollPosition: .top)
		})
	}
	
	// MARK: Actions
	
	/**
	*/
	@objc private func onDimmingViewTap() {
		dismiss(animated: true)
	}
}
