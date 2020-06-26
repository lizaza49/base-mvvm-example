//
//  MaskedTextFieldDelegate+EditingNotifications.swift
//  BaseMVVMExample
//
//  Created by Admin on 22/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import InputMask

///
class NotifyingMaskedTextFieldDelegate: MaskedTextFieldDelegate {
    weak var editingListener: NotifyingMaskedTextFieldDelegateListener?
    
    /**
     */
    convenience init(descriptor: FormInputMaskDescriptor) {
        self.init(primaryFormat: descriptor.format,
                  affineFormats: descriptor.affinity?.formats ?? [],
                  affinityCalculationStrategy: descriptor.affinity?.calculationStrategy ?? .prefix,
                  customNotations: descriptor.notations)
    }
    
    override func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
        ) -> Bool {
        defer {
            self.editingListener?.onEditingChanged(inTextField: textField)
        }
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return editingListener?.textFieldShouldReturn(textField) ?? true
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        editingListener?.textFieldDidBeginEditing(textField)
    }
}

///
protocol NotifyingMaskedTextFieldDelegateListener: class {
    func onEditingChanged(inTextField: UITextField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    func textFieldDidBeginEditing(_ textField: UITextField)
}
