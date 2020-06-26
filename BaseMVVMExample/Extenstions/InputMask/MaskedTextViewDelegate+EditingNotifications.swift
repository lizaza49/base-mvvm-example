//
//  MaskedTextViewDelegate+EditingNotifications.swift
//  BaseMVVMExample
//
//  Created by Elizaveta Alekseeva on 12/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import InputMask

class NotifyingMaskedTextViewDelegate: MaskedTextViewDelegate {
	weak var editingListener: NotifyingMaskedTextViewDelegateListener?
	
	convenience init(descriptor: FormInputMaskDescriptor) {
		self.init(primaryFormat: descriptor.format,
				  affineFormats: descriptor.affinity?.formats ?? [],
				  affinityCalculationStrategy: descriptor.affinity?.calculationStrategy ?? .prefix,
				  customNotations: descriptor.notations)
	}
	
	override func textView(_ textView: UITextView,
						   shouldChangeTextIn range: NSRange,
						   replacementText text: String) -> Bool {
		defer {
			self.editingListener?.onEditingChanged(inTextView: textView)
		}
		return super.textView(textView,
							  shouldChangeTextIn: range,
							  replacementText: text)
	}
	
	override func textViewDidBeginEditing(_ textView: UITextView) {
		super.textViewDidBeginEditing(textView)
		editingListener?.textViewDidBeginEditing(textView)
	}

	
}

protocol NotifyingMaskedTextViewDelegateListener: class {
	func onEditingChanged(inTextView: UITextView)
	//func textViewShouldReturn(_ textField: UITextField) -> Bool
	func textViewDidBeginEditing(_ inTextView: UITextView)
}
