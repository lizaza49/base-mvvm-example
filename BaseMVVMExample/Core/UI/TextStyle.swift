//
//  TextStyle.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class TextStyle {
    
    // MARK: - Properties
    
    let color: UIColor
    let font: UIFont
    let alignment: NSTextAlignment
    let numberOfLines: Int
    
    // MARK: - Initializer
    
    /**
     */
    init(_ color: UIColor, _ font: UIFont, _ alignment: NSTextAlignment = .left, _ numberOfLines: Int = 0) {
        self.color = color
        self.font = font
        self.alignment = alignment
        self.numberOfLines = numberOfLines
    }
}

// MARK: - UI extensions

///
protocol TextStyleApplicable {
    func apply(textStyle: TextStyle)
}

///
extension UILabel: TextStyleApplicable {
    
    func apply(textStyle: TextStyle) {
        self.textColor = textStyle.color
        self.textAlignment = textStyle.alignment
        self.font = textStyle.font
        self.numberOfLines = textStyle.numberOfLines
    }
}

///
extension UITextView: TextStyleApplicable {
    
    func apply(textStyle: TextStyle) {
        self.textColor = textStyle.color
        self.textAlignment = textStyle.alignment
        self.font = textStyle.font
    }
}

///
extension UITextField: TextStyleApplicable {
    func apply(textStyle: TextStyle) {
        self.textColor = textStyle.color
        self.textAlignment = textStyle.alignment
        self.font = textStyle.font
    }
}

///
extension NSMutableAttributedString: TextStyleApplicable {
    
    /**
     */
    func apply(textStyle: TextStyle) {
        self.apply(textStyle: textStyle, ranges: [NSRange(location: 0, length: string.count)])
    }
    
    /**
     */
    func apply(textStyle: TextStyle, ranges: [NSRange]) {
        for range in ranges {
            setAttributes(
                [
                    .font: textStyle.font,
                    .foregroundColor: textStyle.color
                ], range: range)
        }
    }
}
