//
//  BaseFormViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
class BaseFormViewController: BaseViewController, KeyboardAdjustable, NavigationControllerInteractiveTransitionDelegate {
    
    var viewModel: BaseFormViewModelProtocol!
    
    typealias KeyboardAdjustmentTarget = BaseFormViewController
    lazy var keyboardHandler: KeyboardNotificationsHandler<KeyboardAdjustmentTarget> = KeyboardNotificationsHandler(source: self)
    
	let pageControl: PageControlProtocol & UIView = FormStepsPageControl()
    let stepsContainerView = UIView()
    let continueButton = StickyButton(style: .solidCherry)
    
    private var stepViewControllers: NonEmpty<[FormStepViewController]>?
    private var stepsNavigationController: CustomTransitioningNavigationController?
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupBindings()
        observeKeyboardAdjustments()
    }
    
    // MARK: Setup
    
    /**
     */
    func setupViews() {
        pageControl.numberOfPages = viewModel.formSteps.count
        pageControl.currentPage = viewModel.index(of: viewModel.currentStep.value) ?? 0
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(pageControl.bounds.height)
        }
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottomMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(StickyButton.UIConstants.height)
        }
        
        view.insertSubview(stepsContainerView, belowSubview: continueButton)
        stepsContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(pageControl.snp.bottom)
            make.bottom.equalTo(continueButton.snp.top)
            make.left.right.equalToSuperview()
        }
    }
    
    /**
     */
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: Asset.NavBar.backButton.image, style: .plain, target: self, action: #selector(backTap))
        navigationItem.leftBarButtonItem = backButton
    }
    
    /**
     */
    private func setupBindings() {
        // navigation
        viewModel.currentStep.asObservable()
            .takeUntil(rx.deallocated)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .scan((prev: viewModel.currentStep.value, next: viewModel.currentStep.value), accumulator: {
                return ($0.next, $1)
            })
            .subscribe(onNext: {
                guard $0.next.rawValue != $0.prev.rawValue else { return }
                if let currentStepIndex = self.viewModel.currentStepIndex {
                    self.pageControl.currentPage = currentStepIndex
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        // button
        viewModel.buttonText.asObservable()
            .bind(to: continueButton.rx.title())
            .disposed(by: viewModel.disposeBag)
        Observable.combineLatest(viewModel.buttonIsEnabled.asObservable(),
                                 viewModel.isLoading.asObservable(),
                                 resultSelector: { $0 && !$1 })
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)
        continueButton.rx.tap.bind {
            self.view.endEditing(true)
            self.viewModel.viewDidTapContinue()
            self.pushStep()
            }.disposed(by: viewModel.disposeBag)
    }
    
    // MARK: Configuration
    
    /**
     */
    func configureSteps(with viewControllers: NonEmpty<[FormStepViewController]>) {
        self.stepViewControllers = viewControllers
        stepsNavigationController = CustomTransitioningNavigationController(rootViewController: viewControllers.first)
        stepsNavigationController?.transitionManager = SmoothSlideTransitionManager()
        stepsNavigationController?.interactiveTransitionDelegate = self
        stepsNavigationController?.setNavigationBarHidden(true, animated: false)
        self.add(childVC: stepsNavigationController!, to: stepsContainerView)
    }
    
    /**
     */
    private func pushStep() {
        guard
            let stepIndex = viewModel.index(of: viewModel.currentStep.value),
            stepIndex < (stepViewControllers?.count ?? 0),
            let stepVC = stepViewControllers?[stepIndex]
        else { return }
        stepsNavigationController?.pushViewController(stepVC, animated: true)
    }
    
    /**
     */
    private func popStep() {
        stepsNavigationController?.popViewController(animated: true)
    }
    
    // MARK: Actions
    
    /**
     */
    @objc private func backTap() {
        viewModel.viewDidTapBack()
        if (navigationController?.viewControllers ?? []).count > 1 {
            popStep()
        }
    }
    
    // MARK: NavigationControllerInteractiveTransitionDelegate conformance
    
    ///
    var allowsInteractivePop: Bool {
        return viewModel.currentStepIndex ?? 0 != 0
    }
    
    /**
     */
    @objc func navigationController(_ navigationController: UINavigationController, interactiveOperation: UINavigationControllerOperation, didComplete: Bool) {
        if didComplete, interactiveOperation == .pop {
            viewModel.viewDidTapBack()
        }
    }
}

/// KeyboardFrameListener conformance
extension BaseFormViewController: KeyboardFrameListener {
    
    /**
     */
    func keyboardFrameWillChange(frame: CGRect) {
        let visibleFrameHeight = view.bounds.height - frame.minY
        if visibleFrameHeight == 0 {
            continueButton.snp.updateConstraints { (make) in
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        }
        else {
            var bottomMarginHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                bottomMarginHeight = view.safeAreaInsets.bottom
            }
            continueButton.snp.updateConstraints { (make) in
                make.bottom.equalTo(view.snp.bottomMargin).offset(min(0, bottomMarginHeight - visibleFrameHeight))
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
