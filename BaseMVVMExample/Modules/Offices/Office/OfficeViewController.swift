//
//  OfficeViewController.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 14/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
final class OfficeViewController: UIViewController {
	
	var viewModel: OfficeViewModelProtocol!
	
	private let pickerSection = CollectionSection()
	private let headingSection = CollectionSection()
	private let scheduleSection = CollectionSection()
	private let phoneSection = CollectionSection()
	private let optionsSection = CollectionSection()
	
	///
	private lazy var collectionView: UICollectionView = {
		var layout = UICollectionViewFlowLayout()
		switch viewModel.displayStyle {
		case .popup:
			layout = Office.PopupCollectionViewFlowLayout()
			break
		case .listItem:
			layout = Office.OfficeListCollectionViewFlowLayout()
			break
		}
		let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
		return collectionView
	}()
	private var director: CollectionDirector!
	
	
	// MARK: Life cycle
	
	/**
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
	}
	
	// MARK: Setup
	
	/**
	*/
	private func setupViews() {
		setupCollectionView()
		configureCollectionView()
	}
	
	/**
	*/
	private func setupCollectionView() {
		view.addSubview(collectionView)
		collectionView.isScrollEnabled = false
		collectionView.alwaysBounceVertical = false
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		collectionView.allowsMultipleSelection = false
		
		director = CollectionDirector(colletionView: collectionView)
		director.shouldUseAutomaticViewRegistration = true
	}
	
	/**
	*/
	private func configureCollectionView() {
		director.sections.removeAll()
		
		if case let OfficeViewDisplayStyle.popup(displayStyle: dispStyle) = viewModel.displayStyle, dispStyle == .normal {
			configureForNormal()
		}
		
		if case let OfficeViewDisplayStyle.listItem(displayStyle: dispStyle) = viewModel.displayStyle, dispStyle == .normal {
			configureForNormal()
		}
		
		if case let OfficeViewDisplayStyle.popup(displayStyle: dispStyle) = viewModel.displayStyle, dispStyle == .picker {
			configureForPicker()
		}
		
		if case let OfficeViewDisplayStyle.listItem(displayStyle: dispStyle) = viewModel.displayStyle, dispStyle == .picker {
			configureForPicker()
		}
	}
	
	private func configureForPicker() {
		configurePickerSection()
		
		director.reload()
	}
	
	private func configurePickerSection() {
		pickerSection.clear()
		let pickerItem = CollectionItem<OfficePickerCollectionViewCell>(item: viewModel)
		pickerItem.onSelect = { [weak self] _ in
			self?.viewModel.viewDidPickItem()
		}
		pickerSection += pickerItem
		director += pickerSection
	}
	
	private func configureForNormal() {
		configureHeadingItem()
		configureScheduleSection()
		configurePhonesSection(with: viewModel?.phones ?? [])
		configureOptionsSection()
		
		director.reload()
	}
	
	private func configureHeadingItem() {
		headingSection.clear()
		let headingItem = CollectionItem<OfficeHeadingCollectionViewCell>(item: viewModel)
		headingItem.onSelect = { [weak self] _ in
			self?.viewModel.toggleExpansionState()
		}
		headingSection += headingItem
		
		director += headingSection
	}
	
	private func configurePhonesSection(with phonesViewModels: [OfficePhoneViewModelProtocol]) {
		phoneSection.clear()
		guard !phonesViewModels.isEmpty else { return }
		phoneSection.lineSpacing = 1
		phoneSection.append(items: phonesViewModels.map { phoneVM in
			let item = CollectionItem<OfficePhoneCollectionViewCell>(item: phoneVM)
			item.onSelect = { [unowned self] _ in
				self.viewModel.viewDidRequestCall(phone: phoneVM.getFormattedPhone())
			}
			return item
		})
		director += phoneSection
	}
	
	private func configureScheduleSection() {
		guard let schedule = viewModel?.workingSchedule,
				schedule != "" else { return }
		scheduleSection.clear()
		let scheduleViewModel = OfficeScheduleViewModel(schedule: schedule)
		let item = CollectionItem<OfficeScheduleCollectionViewCell>(item: scheduleViewModel)
		scheduleSection += item
		director += scheduleSection
	}
	
	private func configureOptionsSection() {
		guard let options = viewModel?.options,
					!options.isEmpty else { return }
		optionsSection.clear()
		optionsSection.lineSpacing = 1
		optionsSection.append(items: options.map { keyValueVM in
			let item = CollectionItem<OfficeKeyValueCollectionViewCell>(item: keyValueVM)
			return item
		})
		director += optionsSection
	}
	
	/**
	*/
	func reload() {
		guard director != nil else { return }
		configureCollectionView()
	}
}
