//
//  DashboardViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

/// Components structure
struct Dashboard {
    struct Banner {}
    struct Policies {
        struct Slider {}
        struct PurchaseSuggestion {}
    }
    struct SpecialOffers {}
}

///
protocol DashboardViewModelProtocol: BaseViewModelProtocol {
    var router: DashboardRouterProtocol { get }
    var sectionHeaders: [DashboardSectionHeader: CollectionSectionHeaderViewModelProtocol] { get }
    var promoBannerViewModel: Variable<PromoBannerViewModelProtocol?> { get }
    var policiesCategoriesPickerViewModel: Variable<DashboardPoliciesCategoryPickerViewModelProtocol?> { get }
    var policiesSliderViewModel: Variable<DashboardPoliciesSliderViewModelProtocol?> { get }
    var policyPurchaseSuggestionViewModel: Variable<Dashboard.Policies.PurchaseSuggestion.ViewModelProtocol?> { get }
    var personalOffersListViewModel: Variable<PersonalOffersListViewModelProtocol?> { get }
    
    var selectedPoliciesCategory: Variable<PolicyCategoryViewModelProtocol?> { get }
    var contentOffsetY: Variable<Float> { get }
    
    func loadContent()
    func viewDidSelectPromoBanner()
}

///
final class DashboardViewModel: BaseViewModel, DashboardViewModelProtocol {
    
    let router: DashboardRouterProtocol
    
    var sectionHeaders: [DashboardSectionHeader: CollectionSectionHeaderViewModelProtocol] = [:]
    let promoBannerViewModel = Variable<PromoBannerViewModelProtocol?>(PromoBannerViewModel.dummy)
    let policiesCategoriesPickerViewModel: Variable<DashboardPoliciesCategoryPickerViewModelProtocol?>
    let policiesSliderViewModel: Variable<DashboardPoliciesSliderViewModelProtocol?>
    let policyPurchaseSuggestionViewModel: Variable<Dashboard.Policies.PurchaseSuggestion.ViewModelProtocol?>
    let personalOffersListViewModel = Variable<PersonalOffersListViewModelProtocol?>(PersonalOffersListViewModel.dummy)
    
    let selectedPoliciesCategory = Variable<PolicyCategoryViewModelProtocol?>(nil)
    let contentOffsetY = Variable<Float>(0)
    
    private var policies: [PolicyItemViewModelProtocol] = []
    
    private lazy var dashboardService: DashboardServiceProtocol = DashboardService()
    private lazy var policiesService: PoliciesServiceProtocol = PoliciesService()
    
    /**
     */
    required init(router: DashboardRouterProtocol) {
        self.router = router
        policiesCategoriesPickerViewModel = Variable(User.shared.isAuthorized ? DashboardPoliciesCategoryPickerViewModel.dummy : nil)
        policiesSliderViewModel = Variable(User.shared.isAuthorized ? Dashboard.Policies.Slider.ViewModel.dummy : nil)
        policyPurchaseSuggestionViewModel = Variable(User.shared.isAuthorized ? nil :
            Dashboard.Policies.PurchaseSuggestion.ViewModel.default)
        super.init()
        sectionHeaders = [
            .personalOffers: configureSectionHeader(for: .personalOffers, hasAllButton: false)
        ]
        if User.shared.isAuthorized {
            sectionHeaders[.myPolicies] = configureSectionHeader(for: .myPolicies, hasAllButton: true)
        }
        setupBindings()
    }
    
    /**
     */
    private func setupBindings() {
        selectedPoliciesCategory.asObservable()
            .skipUntil(policiesSliderViewModel.asObservable())
            .subscribe(onNext: configurePoliciesSlider)
            .disposed(by: disposeBag)
        if let purchaseSuggestion = policyPurchaseSuggestionViewModel.value {
            purchaseSuggestion.tapAction
                .bind { self.viewDidTapPurhasePolicySuggestion() }
                .disposed(by: purchaseSuggestion.disposeBag)
        }
    }
    
    // MARK: Loading content
    
    /**
     */
    func loadContent() {
        loadBanner()
        loadPolicies()
        loadPersonalOffers()
    }
    
    /**
     */
    private func loadBanner() {
        dashboardService.getBanner()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .asObservable()
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { response in
                let promoBannerViewModel = PromoBannerViewModel(with: response)
                self.contentOffsetY.asObservable()
                    .bind(to: promoBannerViewModel.scrollContentOffsetY)
                    .disposed(by: self.disposeBag)
                self.promoBannerViewModel.value = promoBannerViewModel
            }, onError: { error in
                self.promoBannerViewModel.value = nil
                self.router.present(error: error)
            }).disposed(by: disposeBag)
    }
    
    /**
     */
    private func loadPolicies() {
        policiesService.getPolicies()
            .takeUntil(rx.deallocated)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: {
                if User.shared.isAuthorized {
                    self.configure(policiesCategories: $0.policyCategories)
                    self.configure(policies: $0.policies ?? [])
                }
            }, onError: { error in
                self.router.present(error: error)
                if User.shared.isAuthorized {
                    self.configure(policiesCategories: [])
                    self.configure(policies: [])
                }
            }).disposed(by: disposeBag)
    }
    
    /**
     */
    private func loadPersonalOffers() {
        dashboardService.gerPersonalOffers()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: configure, onError: { error in
                self.configure(personalOffers: [])
                self.router.present(error: error)
            }).disposed(by: disposeBag)
    }

    // MARK: Configuration
    
    /**
     */
    private func configure(policiesCategories: [PolicyCategory]) {
        let categoriesViewModels = policiesCategories.map {
            PolicyCategoryViewModel(category: $0)
        }
        guard !categoriesViewModels.isEmpty else {
            policiesCategoriesPickerViewModel.value = nil
            return
        }
        var pickedCategory: PolicyCategoryViewModelProtocol! = categoriesViewModels.first
        if let currentlyPickedOne = selectedPoliciesCategory.value {
            pickedCategory = categoriesViewModels.first(where: { $0.id == currentlyPickedOne.id }) ?? categoriesViewModels.first
        }
        let pickerViewModel = DashboardPoliciesCategoryPickerViewModel(
            categories: categoriesViewModels,
            pickedCategory: pickedCategory)
        pickerViewModel.pickedCategory.asObservable()
            .bind(to: selectedPoliciesCategory)
            .disposed(by: pickerViewModel.disposeBag)
        self.policiesCategoriesPickerViewModel.value = pickerViewModel
        self.selectedPoliciesCategory.value = pickedCategory
    }
    
    /**
     */
    private func configure(policies: [Policy]) {
        let policiesViewModels = policies.map { policy -> PolicyItemViewModelProtocol in
            let policyViewModel = PolicyItemViewModel(with: policy)
            policyViewModel.prolongateButtonTap
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: {
                    self.viewDidRequestPolicyProlongation(policyViewModel)
                }).disposed(by: disposeBag)
            return policyViewModel
        }
        self.policies = policiesViewModels
        configurePoliciesSlider(with: selectedPoliciesCategory.value)
    }
    
    /**
     */
    private func configurePoliciesSlider(with selectedCategory: PolicyCategoryViewModelProtocol?) {
        guard let selectedCategory = selectedCategory else {
            policiesSliderViewModel.value = nil
            return
        }
        let filteredPolicies = self.policies.filter { $0.categoryViewModel.id == selectedCategory.id }
        let purchaseSuggestion = Dashboard.Policies.PurchaseSuggestion.ViewModel.make(backgroundImageUrl: selectedCategory.backgroundImageUrl)
        let purchaseSuggestionTapDisposable = purchaseSuggestion.tapAction
            .bind { self.viewDidTapPurhasePolicySuggestion() }
        let sliderViewModel = Dashboard.Policies.Slider.ViewModel(
            policies: filteredPolicies,
            selectedItemIndex: 0,
            purchaseSuggestion: purchaseSuggestion)
        sliderViewModel.tapAction
            .subscribeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: viewDidTap)
            .disposed(by: sliderViewModel.disposeBag)
        purchaseSuggestionTapDisposable.disposed(by: sliderViewModel.disposeBag)
        policiesSliderViewModel.value = sliderViewModel
    }
    
    /**
     */
    private func configure(personalOffers: [PersonalOffer]) {
        let offersViewModels = personalOffers.map { offer -> PersonalOfferViewModelProtocol in
            let offerViewModel = PersonalOfferViewModel(with: offer)
            offerViewModel.tapEvent.asObservable()
                .subscribeOn(ConcurrentMainScheduler.instance)
                .subscribe(onNext: viewDidSelectPersonalOffer)
                .disposed(by: disposeBag)
            return offerViewModel
        }
        personalOffersListViewModel.value = offersViewModels.isEmpty ? nil : PersonalOffersListViewModel(offersViewModels: offersViewModels)
    }
    
    /**
     */
    private func configureSectionHeader(for sectionType: DashboardSectionHeader, hasAllButton: Bool, topInset: Float = 0) -> CollectionSectionHeaderViewModelProtocol {
        let viewModel = CollectionSectionHeaderViewModel(sectionType: sectionType, hasAllButton: hasAllButton, topInset: topInset)
        viewModel.tapEvent.asObservable()
            .subscribeOn(ConcurrentMainScheduler.instance)
            .bind(onNext: viewDidRequestAllItems)
            .disposed(by: disposeBag)
        return viewModel
    }
    
    // MARK: Actions
    
    /**
     */
    func viewDidSelectPromoBanner() {
        router.presentDevelopmentAlert()
    }
    
    /**
     */
    private func viewDidSelectPersonalOffer(_ personalOffer: PersonalOfferViewModelProtocol) {
        router.presentDevelopmentAlert()
    }
    
    /**
     */
    private func viewDidRequestAllItems(of sectionType: CollectionSectionTypeProtocol) {
        guard let section = sectionType as? DashboardSectionHeader else { return }
        switch section {
        case .myPolicies:
            MainTabBarRouter.shared.switchToTab(.policies)
            break
        default: break
        }
    }
    
    /**
     */
    private func viewDidTap(policy: PolicyItemViewModelProtocol) {
        router.showPolicyDetails(policyViewModel: policy)
    }
    
    /**
     */
    private func viewDidRequestPolicyProlongation(_ policyViewModel: PolicyItemViewModelProtocol) {
        guard let url = policyViewModel.prolongationURL else { return }
        router.present(url: url, mode: .local, title: L10n.Common.Policy.Prolongation.screenTitle)
    }
    
    /**
     */
    private func viewDidTapPurhasePolicySuggestion() {
        MainTabBarRouter.shared.switchToTab(.purchase)
    }
}
