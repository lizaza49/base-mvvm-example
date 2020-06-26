//
//  RemoteItemPickerViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 18/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit
import RxSwift

///
class RemoteItemPickerViewController: BaseViewController, UISearchControllerDelegate, KeyboardAdjustable {
    
    var viewModel: RemoteItemPickerViewModelProtocol!
    
    typealias KeyboardAdjustmentTarget = RemoteItemPickerViewController
    lazy var keyboardHandler: KeyboardNotificationsHandler<KeyboardAdjustmentTarget> = KeyboardNotificationsHandler(source: self)
    
    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    }()
    private lazy var director = CollectionDirector(colletionView: collectionView)
    private lazy var searchBar: UISearchBar = {
        if #available(iOS 11, *) {
            return searchController.searchBar
        }
        else {
            let bar = UISearchBar()
            bar.tintColor = Color.cherry
            bar.placeholder = L10n.Common.Component.SearchBar.placeholder
            return bar
        }
    }()
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.delegate = self
        return controller
    }()
    private lazy var doneButton = StickyButton(style: .solidCherry)
    
    override var navBarIsUnderlined: Bool {
        if #available(iOS 11, *) {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: Lifestyle
    
    /**
     */
    override func viewDidLoad() {
        view.backgroundColor = Color.white
        super.viewDidLoad()
        setupViews()
        setupBindings()
        observeKeyboardAdjustments()
    }
    
    /**
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.searchBar.becomeFirstResponder()
        })
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupBindings() {
        searchBar.rx.text.asObservable()
            .skipRepeats()
            .bind(to: viewModel.searchQuery)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.searchResults
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: configureCollectionView)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.pickedItem.map { $0 != nil }
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)
        doneButton.rx.tap.bind(to: viewModel.doneTapControlEvent)
            .disposed(by: viewModel.disposeBag)
    }
    
    /**
     */
    private func setupViews() {
        navigationItem.title = viewModel.screenTitle
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.Common.Component.SearchBar.placeholder
        searchController.hidesNavigationBarDuringPresentation = false
        searchBar.tintColor = Color.cherry
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        } else {
            searchBar.sizeToFit()
            view.addSubview(searchBar)
            searchBar.snp.makeConstraints { (make) in
                make.top.equalTo(view.snp.topMargin)
                make.left.right.equalToSuperview()
            }
        }
        
        doneButton.setTitle(L10n.Common.Common.Button.next, for: .normal)
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(StickyButton.UIConstants.height)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        setupCollectionView()
    }
    
    /**
     */
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11, *) {
                make.top.left.right.equalToSuperview()
            }
            else {
                make.top.equalTo(searchBar.snp.bottom)
                make.left.right.equalToSuperview()
            }
            make.bottom.equalTo(doneButton.snp.top)
        }
    }
    
    /**
     */
    private func configureCollectionView(with items: [RemoteItemPickerCellViewModelProtocol]) {
        director.clear()
        let section = CollectionSection()
        section.append(items: items.map { vm in
            let item = CollectionItem<RemoteItemPickerCollectionViewCell>(item: vm)
            item.onSelect = { [weak self] in
                self?.viewModel.viewDidSelectItem(at: $0.item)
            }
            return item
        })
        director.append(section: section)
        director.reload()
    }
}

/// KeyboardFrameListener conformance
extension RemoteItemPickerViewController: KeyboardFrameListener {
    
    /**
     */
    func keyboardFrameWillChange(frame: CGRect) {
        let visibleFrameHeight = UIScreen.main.bounds.height - frame.minY
        if visibleFrameHeight == 0 {
            doneButton.snp.updateConstraints { (make) in
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        }
        else {
            var bottomMarginHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                bottomMarginHeight = view.safeAreaInsets.bottom
            }
            doneButton.snp.updateConstraints { (make) in
                make.bottom.equalTo(view.snp.bottomMargin).offset(min(0, bottomMarginHeight - visibleFrameHeight))
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
