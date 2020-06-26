//
//  FullNameInputStepViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class FullNameInputStepViewController: FormStepViewController {
    
    // KeyboardAdjustable stuff
    override func localKeyboardHandler<T: CollectionKeyboardAdjustable>(adjustableTarget: T) -> KeyboardNotificationsHandler<T> where T.KeyboardAdjustmentTarget: FormStepViewController {
        return KeyboardNotificationsHandler(source: adjustableTarget)
    }
    override var defaultCollectionBottomContentInset: CGFloat {
        return 0
    }
    
    ///
    private var localViewModel: FullNameInputStepViewModelProtocol {
        return viewModel as! FullNameInputStepViewModelProtocol
    }
    
    ///
    private let applyButton = StickyButton(style: .solidCherry)
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = localViewModel.screenTitle
        setupViews()
        setupBindings()
    }
    
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    /**
     */
    private func setupViews() {
        applyButton.setTitle(L10n.Common.FullNamePicker.submitButton, for: .normal)
        view.addSubview(applyButton)
        applyButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottomMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(StickyButton.UIConstants.height)
        }
        
        collectionView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(applyButton.snp.top)
            make.left.right.top.equalToSuperview()
        }
    }
    
    /**
     */
    private func setupBindings() {
        applyButton.rx.tap
            .bind { self.localViewModel.viewDidTapApplyButton() }
            .disposed(by: viewModel.disposeBag)
        
        viewModel.filledWithValidData.asObservable().share()
            .bind(to: applyButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)
    }
}

/// KeyboardFrameListener conformance
extension FullNameInputStepViewController: KeyboardFrameListener {
    
    /**
     */
    func keyboardFrameWillChange(frame: CGRect) {
        let visibleFrameHeight = UIScreen.main.bounds.height - frame.minY
        if visibleFrameHeight == 0 {
            applyButton.snp.updateConstraints { (make) in
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        }
        else {
            var bottomMarginHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                bottomMarginHeight = view.safeAreaInsets.bottom
            }
            applyButton.snp.updateConstraints { (make) in
                make.bottom.equalTo(view.snp.bottomMargin).offset(min(0, bottomMarginHeight - visibleFrameHeight))
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
