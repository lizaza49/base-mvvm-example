//
//  DocumentViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 16/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import QuickLook

///
final class DocumentViewController: BaseViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    var viewModel: DocumentViewModelProtocol!
    
    ///
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = Color.loaderGray
        activityIndicatorView.backgroundColor = UIConstants.activityIndicatorBg
        activityIndicatorView.layer.cornerRadius = UIConstants.activityIndicatorCornerRadius
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    ///
    private let quickLookContainerView = UIView()
    ///
    private lazy var quickLookVC = QLPreviewController()
    ///
    private let shareButton = UIBarButtonItem(image: Asset.NavBar.shareButton.image,
                                      style: .plain, target: nil, action: nil)
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }
    
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        if isMovingFromParentViewController {
            viewModel.removeLocalFile()
        }
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupViews() {
        view.backgroundColor = Color.backgroundGray
        
        navigationItem.title = viewModel.title
        shareButton.rx.tap.bind { self.viewModel.viewDidRequestSharing() }
            .disposed(by: viewModel.disposeBag)
        navigationItem.rightBarButtonItem = shareButton
        
        quickLookContainerView.alpha = 0
        view.addSubview(quickLookContainerView)
        quickLookContainerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.snp.topMargin)
        }
        
        quickLookVC.dataSource = self
        quickLookVC.delegate = self
        add(childVC: quickLookVC, to: quickLookContainerView)
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(UIConstants.activityIndicatorSize)
        }
    }
    
    /**
     */
    private func setupBindings() {
        viewModel.isLoading.bind(to: activityIndicator.rx.isAnimating).disposed(by: viewModel.disposeBag)
        viewModel.documentLocalUrl
            .takeUntil(rx.deallocated)
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { url in
                self.quickLookVC.reloadData()
                self.quickLookContainerView.fadeIn()
            }).disposed(by: viewModel.disposeBag)
        viewModel.documentItem.asObservable()
            .map { $0 != nil }
            .bind(to: shareButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)
    }
    
    /**
     */
    private func share() {
        viewModel.viewDidRequestSharing()
    }
    
    // MARK: QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        let numberOfFiles = viewModel.documentItem.value == nil ? 0 : 1
        return numberOfFiles
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return viewModel.documentItem.value ?? DocumentItem(itemURL: nil)
    }
}

///
fileprivate struct UIConstants {
    static let activityIndicatorSize = CGSize(width: 65, height: 65)
    static let activityIndicatorBg = Color.shadeOfGray
    static let activityIndicatorCornerRadius: CGFloat = 5
}

