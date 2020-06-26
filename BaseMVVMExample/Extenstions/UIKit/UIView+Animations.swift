//
//  UIView+Animations.swift
//  BaseMVVMExample
//
//  Created by Admin on 13/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension UIView {
    
    /**
     */
    func fadeIn(duration: Double = 0.3, alpha: CGFloat = 1.0, completion: (() -> Void)? = nil) {
        fade(with: duration, to: alpha, completion: completion)
    }
    
    /**
     */
    func fadeOut(duration: Double = 0.3, alpha: CGFloat = 0.0, completion: (() -> Void)? = nil) {
        fade(with: duration, to: alpha, completion: completion)
    }
    
    /**
     */
    func fade(with duration: Double = 0.3, to alpha: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        }, completion: {_ in
            completion?()
        })
    }
    
    /**
     */
    func shake(duration: Double = 0.5, amplitude: CGFloat = 10.0, completion: ((Bool) -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: amplitude, y: 0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransform(translationX: -0.8 * amplitude, y: 0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.20, animations: {
                self.transform = CGAffineTransform(translationX: 0.5 * amplitude, y: 0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.15, animations: {
                self.transform = CGAffineTransform(translationX: -0.2 * amplitude, y: 0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.85, relativeDuration: 0.15, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }, completion: completion)
    }
    
    /**
     */
    func applyTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
        layer.anchorPoint = anchorPoint
        let scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
        let xPadding = 1/scale * (anchorPoint.x - 0.5)*bounds.width
        let yPadding = 1/scale * (anchorPoint.y - 0.5)*bounds.height
        transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xPadding, y: yPadding)
    }
}
