//
//  SmsConfirmationViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
final class SmsConfirmationViewController: BaseViewController, KeyboardAdjustable {
    
    var viewModel: SmsConfirmationViewModelProtocol!
    
    typealias KeyboardAdjustmentTarget = SmsConfirmationViewController
    lazy var keyboardHandler: KeyboardNotificationsHandler<KeyboardAdjustmentTarget> = KeyboardNotificationsHandler(source: self)
    
    private let descriptionLabel = UILabel()
    private lazy var codeInputView = ConfirmationCodeInputView(
        frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 45)),
        viewModel: viewModel.codeInputViewModel)
    private let timerLabel = UILabel()
    private let resendButton = BaseButton()
    private let loaderView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override var navBarIsUnderlined: Bool {
        return false
    }
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        observeKeyboardAdjustments()
        setupBindings()
        viewModel.resendCode()
    }
    
    /**
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        codeInputView.startEditing()
    }
    
    // MARK: Setup
    
    /**
     */
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        let closeButton = UIBarButtonItem(image: Asset.Common.commonCross.image, style: .plain, target: nil, action: nil)
        closeButton.rx.tap
            .bind { self.viewModel.viewDidTapClose() }
            .disposed(by: viewModel.disposeBag)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    /**
     */
    private func setupViews() {
        title = L10n.Common.SmsConfirmation.screenTitle
        
        descriptionLabel.apply(textStyle: UIConstants.descTextStyle)
        let patternText = L10n.Common.SmsConfirmation.description("%@")
        var attributedString = NSMutableAttributedString(string: patternText)
        attributedString.apply(textStyle: UIConstants.descTextStyle)
        let phoneString = NSMutableAttributedString(string: viewModel.phoneFormatted)
        phoneString.apply(textStyle: UIConstants.phoneTextStyle)
        attributedString = attributedString.replacing(with: ["%@": [phoneString]])
        descriptionLabel.attributedText = attributedString
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).inset(48)
            make.left.right.equalToSuperview().inset(16)
        }
        
        view.addSubview(codeInputView)
        codeInputView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(60)
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
        
        timerLabel.apply(textStyle: UIConstants.timerTextStyle)
        view.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(codeInputView.snp.bottom).offset(32)
            make.height.equalTo(30)
            make.left.right.equalToSuperview().inset(16)
        }
        
        resendButton.isHidden = true
        resendButton.setTitle(L10n.Common.SmsConfirmation.resendButton, for: .normal)
        resendButton.setTitleColor(Color.cherry, for: .normal)
        resendButton.setTitleColor(Color.cherry.withAlphaComponent(0.5), for: .disabled)
        resendButton.titleLabel?.font = Font.semibold12
        view.addSubview(resendButton)
        resendButton.snp.makeConstraints { (make) in
            make.height.equalTo(UIConstants.resendButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalTo(timerLabel.snp.centerY)
        }
        
        loaderView.hidesWhenStopped = true
        loaderView.color = Color.loaderGray
        view.addSubview(loaderView)
        loaderView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    /**
     */
    private func setupBindings() {
        resendButton.rx.tap.bind {
            self.viewModel.resendCode()
        }.disposed(by: viewModel.disposeBag)
        
        viewModel.resendState.asObservable()
            .takeUntil(rx.deallocated)
            .subscribeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: configure)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.codeInputViewModel.code.asDriver().drive(onNext: {
            if $0.count == self.viewModel.codeInputViewModel.requiredLength {
                self.codeInputView.endEditing()
            }
        }).disposed(by: viewModel.disposeBag)
        
        viewModel.isLoading.asObservable()
            .bind(to: loaderView.rx.isAnimating)
            .disposed(by: viewModel.disposeBag)
        viewModel.isLoading.asObservable()
            .map { !$0 }
            .bind(to: codeInputView.rx.isUserInteractionEnabled)
            .disposed(by: viewModel.disposeBag)
    }
    
    /**
     */
    private func configure(resendState: SmsConfirmationResendState) {
        switch resendState {
        case .enabled, .disabled:
            resendButton.isEnabled = resendState == .enabled
            timerLabel.isHidden = true
            resendButton.isHidden = false
            break
        case .timer(let secondsLeft):
            timerLabel.text = L10n.Common.SmsConfirmation.resendTimerPattern(secondsLeft)
            timerLabel.isHidden = false
            resendButton.isHidden = true
            break
        }
    }
}

///
fileprivate struct UIConstants {
    static let resendButtonHeight: CGFloat = 30
    
    static let descTextStyle = TextStyle(Color.theDarkestGray, Font.regular14, .center)
    static let phoneTextStyle = TextStyle(Color.theDarkestGray, Font.bold14, .center)
    static let timerTextStyle = TextStyle(Color.gray, Font.regular12, .center)
}
