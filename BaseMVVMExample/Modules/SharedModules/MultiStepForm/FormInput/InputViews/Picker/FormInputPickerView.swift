//
//  FormInputPickerView.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class FormInputPickerView<ViewModelType: FormInputPickerViewModelProtocol>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var viewModel: ViewModelType? {
        didSet {
            guard let viewModel = viewModel else {
                self.reloadAllComponents()
                return
            }
            self.reloadAllComponents()
            let row = viewModel.selectedOptionIndex.value ?? 0
            self.selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    /**
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.white
        dataSource = self
        delegate = self
    }
    
    /**
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        viewModel?.selectedOptionIndex.value = selectedRow(inComponent: 0)
    }

    // MARK: UIPickerViewDataSource
    
    /**
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.options.count ?? 0
    }
    
    // MARK: UIPickerViewDelegate
    
    /**
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let viewModel = self.viewModel, component == 0, (0 ..< viewModel.options.count) ~= row else { return nil }
        return viewModel.options[row].asString
    }
    
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel?.selectedOptionIndex.value = row
    }
}
