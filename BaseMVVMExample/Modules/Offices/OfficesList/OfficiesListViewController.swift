//
//  OfficiesListViewController.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alexeeva on 12/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

fileprivate typealias BatchUpdate = () -> Void

///
final class OfficiesListViewController: BaseViewController, UIScrollViewDelegate, KeyboardAdjustable {

	var viewModel: OfficiesListViewModelProtocol!
	typealias KeyboardAdjustmentTarget = OfficiesListViewController
	lazy var keyboardHandler: KeyboardNotificationsHandler<OfficiesListViewController> = KeyboardNotificationsHandler(source: self)
	
	private lazy var searchViewModel: SerachBarViewModelProtocol? = SearchBarViewModel()
	
	private lazy var searchView: SearchBarView = SearchBarView(frame: .zero)
	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	private var director: CollectionDirector!
	
	private var sections: [OfficiesListSectionType: CollectionSection] = [:]
	
	private let lineSpacing: CGFloat = 8
	private let scrollOffsetThresholdToLoadMoreOffices: CGFloat = 100
	
	// MARK: Life cycle
	
	/**
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Color.backgroundGray
		setupSearchBar()
		setupCollectionView()
		configureCollectionView()
		setupViews()
		setupObservers()
		viewModel.onViewDidLoad()
		observeKeyboardAdjustments()
	}
	
	// MARK: Setup
	
	/**
	*/
	private func setupViews() {
		//progress add
	}
	
	private func setupSearchBar() {
		view.addSubview(searchView)
		
		searchView.snp.makeConstraints { (make) in
			if #available(iOS 11.0, *) {
				make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
			} else {
				make.top.equalToSuperview()
			}
			make.left.right.equalToSuperview()
			make.height.equalTo(UIConstants.searchViewHeight)
		}
		
		guard let searchViewModel = searchViewModel else { return }
		searchView.configure(with: searchViewModel)
		
		searchViewModel.searchString
			.asObservable()
			.observeOn(MainScheduler.instance)
			.bind(to: viewModel.searchString)
			.disposed(by: searchViewModel.disposeBag)
	}
	
	private func setupCollectionView() {
		view.addSubview(collectionView)
		collectionView.alwaysBounceVertical = true
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = true
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(searchView.snp.bottom)
			make.left.right.bottom.equalToSuperview()
		}
		
		director = CollectionDirector(colletionView: collectionView)
		director.shouldUseAutomaticViewRegistration = true
		director.scrollDelegate = self
	}
	
	private func configureCollectionView() {
		director.sections.removeAll()
	}
	
	private func setupObservers() {
		viewModel.updatesSignal
			.asObservable()
			.takeUntil(rx.deallocated)
			.observeOn(MainScheduler.instance)
			.bind(onNext: performUpdates)
			.disposed(by: viewModel.disposeBag)
		
		viewModel.itemReloadSignal
			.asObservable()
			.takeUntil(rx.deallocated)
			.observeOn(MainScheduler.instance)
			.skipNil()
			.bind(onNext: reloadItem)
			.disposed(by: viewModel.disposeBag)
	}
	
	/**
	*/
	private func performUpdates(officesListUpdates: [OfficiesListUpdate]) {
		guard !officesListUpdates.isEmpty else { return }
		for update in officesListUpdates {
			switch update {
			case .append(let offices, let section):
				let sectionItemsCount = sections[section]?.items.count ?? 0
				insert(offices: offices, into: section, at: sectionItemsCount)
				break
			case .insert(let offices, let section, let row):
				insert(offices: offices, into: section, at: row)
				break
			case .move(let from, let to):
				move(from: from, to: to)
				break
			case .clear(let section):
				clear(section: section)
				break
			}
		}
	}
	
	/**
	*/
	private func reloadItem(with itemReloadSignal: OfficiesListItemReload) {
		let sectionIndex = index(of: itemReloadSignal.section)
		guard
			sectionIndex < director.sections.count,
			itemReloadSignal.itemIndex < director.sections[sectionIndex].numberOfItems(),
			let sectionOffices = viewModel.officies[itemReloadSignal.section],
			(0 ..< sectionOffices.count) ~= itemReloadSignal.itemIndex
			else {
				return
		}
		let targetIndexPath = IndexPath(row: itemReloadSignal.itemIndex, section: sectionIndex)
		director.performUpdates(updates: {
			collectionView.reloadItems(at: [ targetIndexPath ])
		})
	}
	
	/**
	*/
	private func makeOfficesListItem(with officeViewModel: OfficeViewModelProtocol) -> AbstractCollectionItem {
		let item = CollectionItem<OfficesListItemCollectionViewCell>(item: officeViewModel)
		item.onDisplay = { [weak self] _, cellView in
			guard let `self` = self else { return }
			(cellView as? OfficesListItemCollectionViewCell)?.addViewControllerToParent(viewController: self)
		}
		item.onEndDisplay = { _, cellView in
			(cellView as? OfficesListItemCollectionViewCell)?.removeViewControllerFromParent()
		}
		return item
	}
	
	/**
	*/
	private func index(of section: OfficiesListSectionType) -> Int {
		var index = 0
		for i in 0 ..< OfficiesListSectionType.all.count {
			if i == section.rawValue {
				return index
			}
			else if sections[OfficiesListSectionType(rawValue: i)!] != nil {
				index += 1
			}
		}
		return index
	}
	
	/**
	*/
	private func insert(offices: [OfficeViewModelProtocol], into sectionType: OfficiesListSectionType, at index: Int) {
		director.performUpdates(updates: {
			if let section = sections[sectionType] {
				section.insert(items: offices.map { self.makeOfficesListItem(with: $0) }, at: Array(index ..< index + offices.count))
			}
			else {
				let section = createSection(with: sectionType)
				section.append(items: offices.map { makeOfficesListItem(with: $0) })
				let sectionIndex = self.index(of: sectionType)
				self.director.insert(section: section, at: sectionIndex)
				self.sections[sectionType] = section
			}
		})
	}
	
	/**
	*/
	private func move(from: OfficiesListOfficePointer, to: OfficiesListOfficePointer) {
		guard sections[from.section] != nil else { return }
		let itemToInsert = makeOfficesListItem(with: to.officeViewModel)
		
		// Insert new
		director.performUpdates(updates: {
			var toSection: CollectionSection! = sections[to.section]
			if toSection == nil {
				toSection = createSection(with: to.section)
				toSection += itemToInsert
				let sectionIndex = index(of: to.section)
				director.insert(section: toSection, at: sectionIndex)
				sections[to.section] = toSection
			}
			else {
				sections[to.section]?.insert(item: itemToInsert, at: to.index)
			}
		})
		
		// Delete old
		director.performUpdates(updates: {
			if (sections[from.section]?.items.count ?? 0) == 1 {
				director.remove(section: sections[from.section]!)
				sections.removeValue(forKey: from.section)
			}
			else {
				sections[from.section]?.remove(at: from.index)
			}
		})
	}
	/**
	*/
	private func clear(section: OfficiesListSectionType) {
		if let section = sections[section] {
			director.performUpdates(updates: {
				section.clear()
			})
		}
	}
	
	/**
	*/
	private func createSection(with type: OfficiesListSectionType) -> CollectionSection {
		let section = CollectionSection()
		section.headerItem = CollectionHeaderFooterView<OfficesListCollectionHeaderView>(
			item: type,
			kind: UICollectionElementKindSectionHeader)
		section.lineSpacing = lineSpacing
		return section
	}
	
	// MARK: UIScrollViewDelegate
	
	/**
	*/
	@objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let contentHeight = collectionView.contentSize.height
		if contentHeight > 0 && contentHeight < (scrollView.contentOffset.y + collectionView.bounds.height) + scrollOffsetThresholdToLoadMoreOffices {
		}
	}
}

extension OfficiesListViewController: KeyboardFrameListener {
	func keyboardFrameWillChange(frame: CGRect) {
		let visibleFrameHeight = view.bounds.height - frame.minY
		if visibleFrameHeight == 0 {
			collectionView.snp.updateConstraints { (make) in
				make.bottom.equalToSuperview()
			}
		}
		else {
			var bottomMarginHeight: CGFloat = 0
			if #available(iOS 11.0, *) {
				bottomMarginHeight = view.safeAreaInsets.bottom
			}
			collectionView.snp.updateConstraints { (make) in
				
				make.bottom.equalToSuperview().offset(min(0, bottomMarginHeight - visibleFrameHeight))
			}
		}
		
		self.view.layoutIfNeeded()
	}
}

fileprivate struct UIConstants {
	static let searchViewHeight: CGFloat = 56.0
}
