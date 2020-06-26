//
//  OfficiesWrapperViewController.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
final class OfficiesWrapperViewController: BaseViewController {
	
	var viewModel: OfficiesWrapperViewModelProtocol!
	private var viewContainer = UIView()
	private var continueContainer = UIView()
	
	private lazy var mapVC: OfficesMapViewController = {
		let vc = OfficesMapViewController()
        OfficiesMapModuleConfigurator.configure(with: vc, displayStyle: viewModel.displayStyle, officesService: viewModel.officiesService)
		return vc
	}()
	
	private lazy var listVC: OfficiesListViewController = {
		let vc = OfficiesListViewController()
		OfficiesListModuleConfigurator.configure(with: vc, displayStyle: viewModel.displayStyle, officesService: viewModel.officiesService)
		return vc
	}()
	
	private let filterContainerView = UIView()
	private let continueButton = StickyButton(style: .solidCherry)
	
	// MARK: Life cycle
	
	/**
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		update(displayMode: viewModel.displayMode.value)
		setupObservers()
	}
	
	// MARK: Setup
	
	/**
	*/
	private func setupViews() {
		view.addSubview(continueContainer)
		continueContainer.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.left.right.equalToSuperview()
			make.height.equalTo(viewModel.displayStyle == .picker ? StickyButton.UIConstants.height : 0)
		}
		
		continueContainer.addSubview(continueButton)
		continueButton.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		view.backgroundColor = Color.white
		view.addSubview(viewContainer)
		viewContainer.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.bottom.equalTo(continueContainer.snp.top)
		}
		

		
		view.addSubview(filterContainerView)
		filterContainerView.snp.makeConstraints { (make) in
			make.top.equalTo(view.snp.topMargin)
			make.left.right.bottom.equalToSuperview()
		}
		setupNavigationBar()
	}
	
	private func setupNavigationBar() {

		switch viewModel.displayStyle {
		case .normal:
			navigationItem.titleView = createFilterSelectableTitle()
		case .picker:
			navigationItem.title = L10n.Common.Office.Picker.title
		}
		
		navigationController?.navigationBar.tintColor = Color.cherry
		
		let displayModeButton = UIBarButtonItem(
			image: viewModel.displayMode.value == .map ? Asset.Map.toListMode.image : Asset.Map.toMapMode.image,
			style: .plain,
			target: nil, action: nil)
		
		displayModeButton.rx.tap
			.bind { self.viewModel.toggleDisplayMode() }
			.disposed(by: viewModel.disposeBag)
		
		navigationItem.rightBarButtonItem = displayModeButton

	}
	
	private func createFilterSelectableTitle() -> SelectableNavigationTitleView {
		let titleView = SelectableNavigationTitleView()
		
		titleView.configure(title: viewModel.filter.value?.title ?? L10n.Common.Tabbar.Title.offices)
		viewModel.filter.asObservable()
			.map { $0?.title }
			.bind(to: titleView.rx.title())
			.disposed(by: viewModel.disposeBag)
		titleView.rx.tap
			.bind { self.toggleFilter() }
			.disposed(by: viewModel.disposeBag)
		return titleView
	}
	
	private func toggleFilter() {
		guard !viewModel.filterOptions.isEmpty else { return }
		if viewModel.filterIsDisplayed.value {
			viewModel.router.dismissFilterView()
		}
		else {
			guard let dismissableFilterViewModel =
				viewModel.router.showOfficiesFilter(
				in: filterContainerView,
				options: viewModel.filterOptions,
				selectedOption: viewModel.filter) else { return }
			viewModel.filterIsDisplayed.value = true
			dismissableFilterViewModel.viewWillDismiss.asObservable()
				.map { false }
				.bind(to: viewModel.filterIsDisplayed)
				.disposed(by: dismissableFilterViewModel.disposeBag)
		}
	}
	
	/**
	*/
	@objc private func toggleDisplayMode() {
		viewModel.toggleDisplayMode()
	}
	
	private func setupObservers() {
		viewModel.displayMode
			.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(onNext: { [weak self] mode in
				guard let self = self else { return }
				self.update(displayMode: mode)
				
				if let displayModeButton = self.navigationItem.rightBarButtonItem {
					displayModeButton.image = mode == .map ? Asset.Map.toListMode.image : Asset.Map.toMapMode.image
				}
			})
			.disposed(by: viewModel.disposeBag)
		
		viewModel.filterIsDisplayed.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(to: filterContainerView.rx.isUserInteractionEnabled)
			.disposed(by: viewModel.disposeBag)
		
		listVC.viewModel.pickedItem
			.asObservable()
			.map { officeVm -> Office? in
				return officeVm?.office
		}.bind(to: viewModel.pickedOffice)
		.disposed(by: viewModel.disposeBag)
		
		mapVC.viewModel.selectedOffice
			.asObservable()
			.bind(to: viewModel.pickedOffice)
			.disposed(by: viewModel.disposeBag)
		
		viewModel.continueButtonText.asObservable()
			.bind(to: continueButton.rx.title())
			.disposed(by: viewModel.disposeBag)
		
		viewModel.continueButtonEnabled.asObservable()
			.bind(to: continueButton.rx.isEnabled)
			.disposed(by: viewModel.disposeBag)
		
		continueButton.rx.tap.bind {
			self.viewModel.continueButtonDidTap()
			self.viewModel.router.pop()
			}.disposed(by: viewModel.disposeBag)
	}
	
	private func update(displayMode: OfficiesWrapperDisplayMode) {
		add(childVC: displayMode == .map ? mapVC : listVC, to: viewContainer)
		viewModel.pickedOffice.onNext(displayMode == .map ? mapVC.viewModel.selectedOffice.value : listVC.viewModel.pickedItem.value?.office)
		if childViewControllers.count > 1 {
			remove(childVC: displayMode == .map ? listVC : mapVC)
		}
	}
}
