//
//  OperationResultViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
final class OperationResultViewController: BaseViewController {
    
    var viewModel: OperationResultViewModelProtocol!
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var director = CollectionDirector(colletionView: collectionView)
    
    private var stickyButtons: [StickyButton] = []
    
    private let headingSection = CollectionSection()
    private let contentSection = CollectionSection()
    private let hiddenInfoSection = CollectionSection()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupViews() {
        // buttons
        viewModel.stickyButtons.enumerated().forEach { item in
            let button = StickyButton(style: item.element.style)
            button.setTitle(item.element.text, for: .normal)
            button.rx.tap.bind {
                item.element.action(self.viewModel.router)
            }.disposed(by: viewModel.disposeBag)
            view.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(StickyButton.UIConstants.height)
                if item.offset == 0 {
                    make.bottom.equalTo(view.snp.bottomMargin)
                }
                else {
                    make.bottom.equalTo(stickyButtons[item.offset - 1].snp.top)
                }
            })
            stickyButtons.append(button)
        }
        
        setupCollectionView()
    }
    
    /**
     */
    private func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            if let firstButton = stickyButtons.first {
                make.bottom.equalTo(firstButton.snp.top)
            }
            else {
                make.bottom.equalToSuperview()
            }
        }
        director.shouldUseAutomaticViewRegistration = true
    }
    
    /**
     */
    private func setupBindings() {
        viewModel.hiddenInfoViewModel?.isExpanded
            .asObservable()
            .skipRepeats()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: toggleHiddenInfoItem)
            .disposed(by: viewModel.disposeBag)
    }
    
    // MARK: Configuration
    
    /**
     */
    private func configureCollectionView() {
        director.clear()
        
        configureHeadingSection(with: viewModel.heading, shouldReload: false)
        director += headingSection
        
        configureContentSection(with: viewModel.content, shouldReload: false)
        director += contentSection
        
        configureHiddenSection(with: viewModel.hiddenInfoViewModel, boxedInfoViewModel: viewModel.boxedInfoViewModel, shouldReload: false)
        director += hiddenInfoSection
        
        director.reload()
    }
    
    /**
     */
    private func configureHeadingSection(with headingViewModel: OperationResultHeadingViewModelProtocol, shouldReload: Bool = true) {
        headingSection.clear()
        headingSection += CollectionItem<OperationResultHeadingCollectionViewCell>(item: headingViewModel)
        if shouldReload {
            director.performUpdates(updates: { headingSection.reload() })
        }
    }
    
    /**
     */
    private func configureContentSection(with content: String, shouldReload: Bool = true) {
        contentSection.clear()
        contentSection.insetForSection = UIEdgeInsets(top: 32, left: 0, bottom: 20, right: 0)
        contentSection += CollectionItem<OperationResultContentCollectionViewCell>(item: content)
        if shouldReload {
            director.performUpdates(updates: { contentSection.reload() })
        }
    }
    
    /**
     */
    private func configureHiddenSection(with toggleViewModel: HiddenInfoToggleViewModelProtocol?, boxedInfoViewModel: BoxedInfoViewModelProtocol?, shouldReload: Bool = true) {
        
        defer {
            if shouldReload {
                director.performUpdates(updates: { hiddenInfoSection.reload() })
            }
        }
        
        hiddenInfoSection.clear()
        guard let toggleViewModel = toggleViewModel, let boxedInfoViewModel = boxedInfoViewModel else {
            hiddenInfoSection.insetForSection = .zero
            return
        }
        hiddenInfoSection.insetForSection.bottom = 16
        let toggleItem = CollectionItem<HiddenInfoToggleCollectionViewCell>(item: toggleViewModel)
        toggleItem.onSelect = { [weak self] _ in
            self?.viewModel.hiddenInfoViewModel?.toggleExpansionState()
        }
        hiddenInfoSection += toggleItem
        if (try? toggleViewModel.isExpanded.value()) ?? false {
            hiddenInfoSection += CollectionItem<BoxedInfoCollectionViewCell>(item: boxedInfoViewModel)
        }
    }
    
    /**
     */
    private func toggleHiddenInfoItem(isExpanded: Bool) {
        guard let boxedInfoViewModel = viewModel.boxedInfoViewModel else { return }
        if !isExpanded {
            hideBoxedInfo()
            return
        }
        if hiddenInfoSection.items.count > 1 {
            hideBoxedInfo()
        }
        director.performUpdates(updates: {
            hiddenInfoSection.append(item: CollectionItem<BoxedInfoCollectionViewCell>(item: boxedInfoViewModel))
        })
        collectionView.scrollToItem(at: IndexPath(row: 1, section: 2), at: .centeredVertically, animated: true)
    }
    
    /**
     */
    private func hideBoxedInfo() {
        guard hiddenInfoSection.items.count > 1 else { return }
        collectionView.setContentOffset(.zero, animated: true)
        director.performUpdates(updates: {
            hiddenInfoSection.remove(at: Array(1 ..< hiddenInfoSection.items.count))
        })
    }
}
