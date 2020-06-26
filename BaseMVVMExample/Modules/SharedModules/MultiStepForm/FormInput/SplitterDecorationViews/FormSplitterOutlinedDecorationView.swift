//
//  FormSplitterOutlinedDecorationView.swift
//  BaseMVVMExample
//
//  Created by Admin on 02/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
enum FormSplitterOutlineStyle {
    case topMost
    case theOnly
    case none
}

///
class FormSplitterOutlinedDecorationView: UICollectionReusableView {
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if let style = layoutAttributes.accessibilityElements?.first as? FormSplitterOutlineStyle {
            print("we apply style: \(style)")
        }
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
}
