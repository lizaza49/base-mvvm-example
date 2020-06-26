//
//  SmoothSlideTransitionManager.swift
//  BaseMVVMExample
//
//  Created by Admin on 26/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class SmoothSlideTransitionManager : TransitionManager {
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    // perform the animation(s) to show the transition from one screen to another
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to the container view that we should perform the transition in
        let container = transitionContext.containerView
        
        // get references to our 'from' and 'to' view controllers
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        // get references to the root views of both controllers
        let fromView = fromViewController.view!
        let toView = toViewController.view!
        
        toView.frame = fromView.frame
        toView.center = fromView.center
        
        let leftTransform = CGAffineTransform(translationX: -100, y: 0)
        let rightTransform = CGAffineTransform(translationX: 100, y: 0)
        
        // set the start location of toView depending if we're presenting or not
        fromView.alpha = 1
        toView.alpha = 0
        fromView.transform = .identity
        // add the both views to our view controller
        if forward {
            container.addSubview(fromView)
            container.addSubview(toView)
            toView.transform = rightTransform
        }
        else {
            container.addSubview(toView)
            container.addSubview(fromView)
            toView.transform = leftTransform
        }
        
        // get the duration of the animation
        let duration = self.transitionDuration(using: transitionContext)
        
        self.isAnimating = true
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                fromView.alpha = 0
                fromView.transform = self.forward ? leftTransform : rightTransform
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                toView.alpha = 1
                toView.transform = .identity
            })
        }, completion: { finished in
            self.isAnimating = false
            fromView.transform = .identity
            toView.transform = .identity
            // tell our transitionContext object that we've finished animating
            if transitionContext.transitionWasCancelled {
                fromView.transform = .identity
                if self.forward {
                    toView.transform = rightTransform
                }
                else {
                    toView.transform = leftTransform
                }
                fromView.alpha = 1
                toView.alpha = 0
                transitionContext.completeTransition(false)
            }
            else {
                fromView.transform = .identity
                toView.transform = .identity
                fromView.alpha = 1
                toView.alpha = 1
                transitionContext.completeTransition(true)
            }
        })
    }
}
