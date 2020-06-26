//
//  CALayer+Animations.swift
//  BaseMVVMExample
//
//  Created by Admin on 01/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

/**
 */
extension CALayer {
    
    struct Animation {
        ///
        enum Key: String {
            case opacity
            case shadowOpacity
            case shadowColor
            case shadowOffset
            case shadowRadius
            case strokeEnd
        }
        
        ///
        enum TimingFunction {
            case easeInOut
            
            var name: String {
                switch self {
                case .easeInOut:
                    return kCAMediaTimingFunctionEaseInEaseOut
                }
            }
        }
    }
    
    /**
     */
    func animate(key: Animation.Key,
                 fromValue: Any? = nil,
                 toValue: Any,
                 duration: Double,
                 timingFinction: Animation.TimingFunction = .easeInOut,
                 isRemovedOnCompletion: Bool = false,
                 completion: (() -> Void)? = nil) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: key.rawValue)
        if let fromValue = fromValue as? CGFloat {
            animation.fromValue = NSNumber(value: Float(fromValue))
        }
        else if let fromValue = fromValue as? CGSize {
            animation.fromValue = NSValue(cgSize: fromValue)
        }
        else if let value = value(forKey: key.rawValue) {
            animation.fromValue = value
        }
        if let toValue = toValue as? CGFloat {
            animation.toValue = NSNumber(value: Float(toValue))
        }
        else if let toValue = toValue as? CGSize {
            animation.toValue = NSValue(cgSize: toValue)
        }
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: timingFinction.name)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = isRemovedOnCompletion
        CATransaction.setCompletionBlock(completion)
        self.add(animation, forKey: key.rawValue)
        CATransaction.commit()
    }
    
    /**
     */
    func animateShadow(color: CGColor, offset: CGSize, radius: CGFloat, opacity: Float, duration: Double, timingFinction: Animation.TimingFunction = .easeInOut, isRemovedOnCompletion: Bool = true, completion: (() -> Void)? = nil) {
        let animations: [Animation.Key: Any] = [
            .shadowColor: color,
            .shadowOffset: offset,
            .shadowRadius: radius,
            .shadowOpacity: opacity
        ]
        animations.enumerated().forEach {
            animate(key: $0.element.key,
                    toValue: $0.element.value,
                    duration: duration,
                    timingFinction: timingFinction,
                    isRemovedOnCompletion: isRemovedOnCompletion,
                    completion: $0.offset == animations.count - 1 ? completion : nil)
        }
    }
}
