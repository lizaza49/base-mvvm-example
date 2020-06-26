//
//  FormInputDatePickerView.swift
//  BaseMVVMExample
//
//  Created by Admin on 21/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

///
class FormInputDatePickerView: UIDatePicker {
    
    private var reusableDisposeBag = DisposeBag()
    
    ///
    var viewModel: FormInputDatePickerViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else {
                self.reloadInputViews()
                return
            }
            if let mode: UIDatePickerMode = UIDatePickerMode(rawValue: viewModel.mode.rawValue) {
                datePickerMode = mode
            }
            else {
                datePickerMode = .date
            }
            setupObservers()
        }
    }
    
    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.white
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let selectedDate = viewModel?.selectedDate.value {
            date = selectedDate
        }
        viewModel?.selectedDate.value = date
    }

    /**
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     */
    private func setupObservers() {
        reusableDisposeBag = DisposeBag()
        viewModel?.range.asObservable()
            .subscribe(onNext: updateAcceptableRange)
            .disposed(by: reusableDisposeBag)

        viewModel?.selectedDate.asObservable().share().map {
            date -> Date? in
                guard let viewModel = self.viewModel else { return nil }
                guard let date = date else {
                    let minDate = viewModel.range.value.lowerBound
                    let maxDate = viewModel.range.value.upperBound
                    let initialDate: Date = abs(minDate.timeIntervalSinceNow) < abs(maxDate.timeIntervalSinceNow) ? minDate : maxDate
                    let selectedDate = viewModel.selectedDate.value ?? initialDate
                    return selectedDate
                }
                return date
            }.skipNil().bind(to: rx.date).disposed(by: reusableDisposeBag)
        
        if let vm = viewModel {
            rx.date.skip(1).bind(to: vm.selectedDate).disposed(by: reusableDisposeBag)
        }
    }
    
    /**
     */
    private func updateAcceptableRange(_ range: ClosedRange<Date>) {
        minimumDate = range.lowerBound
        maximumDate = range.upperBound
    }
}
