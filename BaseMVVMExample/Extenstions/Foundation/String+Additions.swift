//
//  String+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension String {
    
    /**
     */
    func height(using font: UIFont) -> CGFloat {
        let attributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: attributes)
        return size.height
    }
    
    /**
     */
    func size(using font: UIFont, boundingWidth: CGFloat, boundingHeight: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let boundingSize = CGSize(width: boundingWidth, height: boundingHeight)
        let boundingRect = self.boundingRect(with: boundingSize, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : font], context: nil)
        return boundingRect.size
    }
    
    /**
     */
    func convertedToLowercasedLatin() -> String? {
        return self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false)
    }
    
    /**
     */
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
