//
//  ShadowStyle.swift
//  BaseMVVMExample
//
//  Created by Admin on 18/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class ShadowStyle {
    
    // MARK: - Properties
    
    let color: UIColor
    let radius: CGFloat
    let offset: CGSize
    let opacity: CGFloat
    
    // MARK: - Initializer
    
    /**
     */
    init(_ color: UIColor, _ radius: CGFloat, _ offset: CGSize = .zero, _ opacity: CGFloat = 1) {
        self.color = color
        self.radius = radius
        self.offset = offset
        self.opacity = opacity
    }
}

// MARK: - UI extensions

///
protocol ShadowStyleApplicable {
    func apply(shadowStyle: ShadowStyle)
    func removeShadow()
}

///
extension UIView: ShadowStyleApplicable {
    
    func apply(shadowStyle: ShadowStyle) {
        layer.apply(shadowStyle: shadowStyle)
    }
    
    func removeShadow() {
        layer.removeShadow()
    }
}

///
extension CALayer: ShadowStyleApplicable {
    func apply(shadowStyle: ShadowStyle) {
        shadowColor = shadowStyle.color.cgColor
        shadowRadius = shadowStyle.radius
        shadowOffset = shadowStyle.offset
        shadowOpacity = Float(shadowStyle.opacity)
    }
    
    func removeShadow() {
        shadowColor = nil
        shadowRadius = 0
        shadowOffset = .zero
        shadowOpacity = 0
    }
}
