//
//  DashboardViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift
import RxCocoa

///
final class DashboardViewController: BaseViewController, UIScrollViewDelegate {
    
    var viewModel: DashboardViewModelProtocol!
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: DashboardCollectionViewFlowLayout())
    private var director: CollectionDirector!
    
    private let bannerSection = CollectionSection()
    private let policyPurchaseSuggestionSection = CollectionSection()
    private let policiesSection = CollectionSection()
    private let personalOffersSection = CollectionSection()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: UI Constants
    private let defaultSectionInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    
    override var hasNavigationBar: Bool {
        return false
    }
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureCollectionView()
        setupBindings()
        
        viewModel.loadContent()
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupViews() {
        view.backgroundColor = Color.backgroundGray
        setupCollectionView()
    }
    
    /**
     */
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        director = CollectionDirector(colletionView: collectionView)
        director.shouldUseAutomaticViewRegistration = true
        director.scrollDelegate = self
    }
    
    /**
     */
    private func setupBindings() {
        viewModel.promoBannerViewModel.asObservable()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { self.configureBannerSection(with: $0) })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.policiesCategoriesPickerViewModel.asObservable()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: reloadPoliciesPicker)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.policyPurchaseSuggestionViewModel.asDriver()
            .drive(onNext: { self.configurePolicyPurchaseSuggestionSection(with: $0) })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.policiesSliderViewModel.asObservable()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: reloadPoliciesSlider)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.personalOffersListViewModel.asObservable()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { self.configurePersonalOffersSection(with: $0) })
            .disposed(by: viewModel.disposeBag)
        
        collectionView.rx.contentOffset.changed
            .asObservable()
            .map { Float($0.y) }
            .bind(to: viewModel.contentOffsetY)
            .disposed(by: viewModel.disposeBag)
    }
    
    // MARK: Configuration
    
    /**
     */
    private func configureCollectionView(shouldReload: Bool = true) {
        director.clear()
        
        configureBannerSection(
            with: viewModel.promoBannerViewModel.value,
            shouldReload: false)
        director += bannerSection
        
        configurePolicyPurchaseSuggestionSection(
            with: viewModel.policyPurchaseSuggestionViewModel.value,
            shouldReload: false)
        director += policyPurchaseSuggestionSection
        
        configurePoliciesSection(
            with: viewModel.policiesCategoriesPickerViewModel.value,
            sliderViewModel: viewModel.policiesSliderViewModel.value,
            shouldReload: false)
        director += policiesSection
        
        configurePersonalOffersSection(
            with: viewModel.personalOffersListViewModel.value,
            shouldReload: false)
        director += personalOffersSection
        
        if shouldReload {
            director.reload()
        }
    }
    
    /**
     */
    private func configureBannerSection(with viewModel: PromoBannerViewModelProtocol?, shouldReload: Bool = true) {
        bannerSection.clear()
        if let viewModel = viewModel {
            bannerSection.insetForSection.top = 0
            bannerSection.insetForSection.bottom = UIConstants.bannerSectionBottomInset
            let item = CollectionItem<PromoBannerCollectionViewCell>(item: viewModel)
            item.onSelect = { [weak self] _ in self?.viewModel.viewDidSelectPromoBanner() }
            bannerSection += item
        }
        else {
            bannerSection.insetForSection.top = topBarHeight
            bannerSection.insetForSection.bottom = 0
        }
        if shouldReload {
            director.performUpdates(updates: { bannerSection.reload() })
        }
    }
    
    /**
     */
    private func configurePoliciesSection(
        with pickerViewModel: DashboardPoliciesCategoryPickerViewModelProtocol?,
        sliderViewModel: DashboardPoliciesSliderViewModelProtocol?,
        shouldReload: Bool = true) {
        policiesSection.clear()
        policiesSection.headerItem = nil
        if let pickerViewModel = pickerViewModel, let sliderViewModel = sliderViewModel {
            if let headerViewModel = self.viewModel.sectionHeaders[.myPolicies] {
                policiesSection.headerItem = CollectionHeaderFooterView<CollectionSectionHeaderView>(item: headerViewModel, kind: UICollectionElementKindSectionHeader)
            }
            policiesSection += CollectionItem<Dashboard.Policies.CategoryPicker.CollectionViewCell>(item: pickerViewModel)
            policiesSection += CollectionItem<Dashboard.Policies.Slider.CollectionViewCell>(item: sliderViewModel)
        }
        if shouldReload {
            director.performUpdates(updates: { policiesSection.reload() })
        }
    }
    
    /**
     */
    private func reloadPoliciesPicker(with pickerViewModel: DashboardPoliciesCategoryPickerViewModelProtocol?) {
        typealias TargetCellType = CollectionItem<Dashboard.Policies.CategoryPicker.CollectionViewCell>
        guard
            let enumeratedItem = policiesSection.items.enumerated().first(where: { $0.element is TargetCellType }),
            let item = enumeratedItem.element as? TargetCellType else {
                configurePoliciesSection(
                    with: pickerViewModel,
                    sliderViewModel: viewModel.policiesSliderViewModel.value)
                return
        }
        if let pickerViewModel = pickerViewModel {
            director.performUpdates(updates: {
                item.reload(item: pickerViewModel)
            })
        }
        else if viewModel.policiesSliderViewModel.value == nil {
            configurePoliciesSection(with: viewModel.policiesCategoriesPickerViewModel.value,
                                     sliderViewModel: viewModel.policiesSliderViewModel.value,
                                     shouldReload: true)
        }
        else {
            director.performUpdates(updates: {
                policiesSection.remove(at: enumeratedItem.offset)
            })
        }
    }
    
    /**
     */
    private func reloadPoliciesSlider(with sliderViewModel: DashboardPoliciesSliderViewModelProtocol?) {
        typealias TargetCellType = CollectionItem<Dashboard.Policies.Slider.CollectionViewCell>
        guard
            let enumeratedItem = policiesSection.items.enumerated().first(where: { $0.element is TargetCellType }),
            let item = enumeratedItem.element as? TargetCellType else {
                configurePoliciesSection(
                    with: viewModel.policiesCategoriesPickerViewModel.value,
                    sliderViewModel: sliderViewModel)
                return
        }
        if let sliderViewModel = sliderViewModel {
            director.performUpdates(updates: {
                item.reload(item: sliderViewModel)
            })
        }
        else if viewModel.policiesCategoriesPickerViewModel.value == nil {
            configurePoliciesSection(with: viewModel.policiesCategoriesPickerViewModel.value,
                                     sliderViewModel: viewModel.policiesSliderViewModel.value,
                                     shouldReload: true)
        }
        else {
            director.performUpdates(updates: {
                policiesSection.remove(at: enumeratedItem.offset)
            })
        }
    }
    
    /**
     */
    private func configurePolicyPurchaseSuggestionSection(with policyPurchaseViewModel: Dashboard.Policies.PurchaseSuggestion.ViewModelProtocol?, shouldReload: Bool = true) {
        policyPurchaseSuggestionSection.clear()
        if let policyPurchaseViewModel = policyPurchaseViewModel {
            policyPurchaseSuggestionSection.insetForSection.bottom = UIConstants.defaultSectionBottomInset
            policyPurchaseSuggestionSection += CollectionItem<Dashboard.Policies.PurchaseSuggestion.CollectionViewCell>(item: policyPurchaseViewModel)
        }
        else {
            policyPurchaseSuggestionSection.insetForSection.bottom = 0
        }
        if shouldReload {
            director.performUpdates(updates: { policyPurchaseSuggestionSection.reload() })
        }
    }
    
    /**
     */
    private func configurePersonalOffersSection(with viewModel: PersonalOffersListViewModelProtocol?, shouldReload: Bool = true) {
        personalOffersSection.clear()
        if let viewModel = viewModel {
            personalOffersSection.insetForSection.bottom = UIConstants.defaultSectionBottomInset
            if let headerViewModel = self.viewModel.sectionHeaders[.personalOffers] {
                personalOffersSection.headerItem = CollectionHeaderFooterView<CollectionSectionHeaderView>(item: headerViewModel, kind: UICollectionElementKindSectionHeader)
            }
            let item = CollectionItem<PersonalOffersListCollectionViewCell>(item: viewModel)
            personalOffersSection += item
        }
        else {
            personalOffersSection.headerItem = nil
            personalOffersSection.insetForSection.bottom = 0
        }
        if shouldReload {
            director.performUpdates(updates: { personalOffersSection.reload() })
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    /**
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO: Adjust status bar style
    }
}

///
fileprivate struct UIConstants {
    static let defaultSectionBottomInset: CGFloat = 30
    static let bannerSectionBottomInset: CGFloat = 14
}
