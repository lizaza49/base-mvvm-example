//
//  UILabel+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 24/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension UILabel {
    
    ///
    var adjustedFontSize: CGFloat {
        guard let text = self.text else { return font.pointSize }
        var currentFont: UIFont = font.withSize(font.pointSize + 1.0)
        let originalFontSize = currentFont.pointSize
        var currentSize: CGSize = .zero
        
        repeat {
            currentFont = currentFont.withSize(currentFont.pointSize - 1.0)
            currentSize = (text as NSString).size(withAttributes: [.font: currentFont])
        } while currentSize.width > frame.size.width && currentFont.pointSize > (originalFontSize * minimumScaleFactor)
        
        return currentFont.pointSize
    }
}
