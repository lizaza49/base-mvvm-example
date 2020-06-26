//
//  KeyboardAdjustable.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

///
class KeyboardNotificationsHandler<AdjustmentsTarget: KeyboardAdjustable>: NSObject {
    unowned let source: AdjustmentsTarget
    var keyboardShouldBeVisible: Bool = false
    
    /**
     */
    init(source: AdjustmentsTarget) {
        self.source = source
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        guard let vc = source as? UIViewController else { return }
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(anywhereTap))
        tapGR.cancelsTouchesInView = false
        vc.view.addGestureRecognizer(tapGR)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    /**
     Used for initialization of a lazy instance
     */
    func launch() {}
    
    // MARK: Notifications
    
    @objc func keyboardWillShow(notification: NSNotification) {}
    @objc func keyboardWillHide(notification: NSNotification) {}
    @objc func keyboardFrameWillChange(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        (source as? KeyboardFrameListener)?.keyboardFrameWillChange(frame: keyboardFrame)
    }
    
    // MARK: Actions
    
    /**
     */
    @objc private func anywhereTap() {
        (self.source as? UIViewController)?.view.endEditing(true)
    }
}

///
protocol KeyboardAdjustable: class {
    associatedtype KeyboardAdjustmentTarget: KeyboardAdjustable
    var keyboardHandler: KeyboardNotificationsHandler<KeyboardAdjustmentTarget> { get set }
}

///
extension KeyboardAdjustable {
    func observeKeyboardAdjustments() {
        keyboardHandler.launch()
    }
}

///
protocol CollectionKeyboardAdjustable: KeyboardAdjustable {
    var collectionView: UICollectionView { get }
    var editingCollectionViewCell: UICollectionViewCell? { get }
}

///
protocol KeyboardFrameListener {
    func keyboardFrameWillChange(frame: CGRect)
}
