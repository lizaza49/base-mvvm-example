//
//  CollectionKeyboardAdjustable.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
final class CollectionKeyboardNotificationsHandler<AdjustmentTarget: CollectionKeyboardAdjustable>: KeyboardNotificationsHandler<AdjustmentTarget> {
    
    private let defaultBottomInset: CGFloat
    private let keyboardTopInset: CGFloat
    
    /**
     */
    init(source: AdjustmentTarget,
         defaultBottomInset: CGFloat = 0,
         keyboardTopInset: CGFloat = 10) {
        self.defaultBottomInset = defaultBottomInset
        self.keyboardTopInset = keyboardTopInset
        super.init(source: source)
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        let collectionView = source.collectionView
        guard
            let vc = source as? UIViewController,
            let editingCollectionViewCell = source.editingCollectionViewCell,
            let editingCellIndexPath = collectionView.indexPath(for: editingCollectionViewCell)
            else {
                return
        }
        if let nc = vc.navigationController, nc.viewControllers.last != vc {
            return
        }
        keyboardShouldBeVisible = true
        
        let info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = CGRect(
            x: keyboardFrame.minX,
            y: keyboardFrame.minY - keyboardTopInset,
            width: keyboardFrame.width,
            height: keyboardFrame.height + keyboardTopInset)
        
        // Find out which field's textField is being edited now
        guard let fieldCellAttributes = collectionView.layoutAttributesForItem(at: editingCellIndexPath) else { return }
        let relativeCellFrame = fieldCellAttributes.frame
        let absoluteCellFrame = collectionView.convert(relativeCellFrame, to: UIScreen.main.coordinateSpace)
        // Adjust scroll so that editing cell would be visible (above keyboard)
        if absoluteCellFrame.intersects(keyboardFrame) {
            let intersectionHeight = absoluteCellFrame.intersection(keyboardFrame).height
           setCollectionContentOffset(collectionView.contentOffset.applying(CGAffineTransform(translationX: 0, y: intersectionHeight)))
        }
        if keyboardShouldBeVisible {
            collectionView.scrollIndicatorInsets.bottom = self.defaultBottomInset + keyboardFrame.height - keyboardTopInset
            // Adjust collection bottom inset to preserve the keyboard height
            UIView.animate(withDuration: 0.2, animations: {
                collectionView.contentInset.bottom = self.defaultBottomInset + keyboardFrame.height
            })
        }
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        guard let vc = source as? UIViewController else { return }
        if let nc = vc.navigationController, nc.viewControllers.last != vc { return }
        keyboardShouldBeVisible = false
        let collectionView = source.collectionView
        collectionView.scrollIndicatorInsets.bottom = defaultBottomInset
        UIView.animate(withDuration: 0.2, animations: {
            collectionView.contentInset.bottom = self.defaultBottomInset
        })
        var topContentInset: CGFloat = collectionView.contentInset.top
        if #available(iOS 11.0, *) {
            topContentInset = collectionView.adjustedContentInset.top
        }
        if topContentInset + collectionView.contentOffset.y < 0 && collectionView.contentSize.height < collectionView.frame.height {
            setCollectionContentOffset(.zero)
        }
    }
    
    /**
     */
    private func setCollectionContentOffset(_ offset: CGPoint) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        source.collectionView.setContentOffset(offset, animated: true)
        CATransaction.commit()
    }
}
