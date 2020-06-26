//
//  TransitionManager.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class TransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var forward = true
    var interactive = false
    var isAnimating = false
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.forward = true
        return self
    }
    
    // what UIViewControllerAnimatedTransitioning object to use for presenting
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?  {
        self.forward = false
        return self
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    // MARK: UIViewControllerAnimatedTransitioning methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    // perform the animation(s) to show the transition from one screen to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Delegate to child classes
    }
}

///
class CrossDissolveTransitionManager : TransitionManager {
    
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
        
        // set the start location of toView depending if we're presenting or not
        fromView.alpha = 1
        toView.alpha = 0
        // add the both views to our view controller
        if forward {
            container.addSubview(fromView)
            container.addSubview(toView)
        }
        else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
        
        // get the duration of the animation
        let duration = self.transitionDuration(using: transitionContext)
        
        let options = interactive ? UIViewAnimationOptions.curveLinear : UIViewAnimationOptions.curveEaseOut
        
        isAnimating = true
        
        // perform the animation
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            toView.alpha = 1
            fromView.alpha = 0
        }, completion: { finished in
            // tell our transitionContext object that we've finished animating
            self.isAnimating = false
            if(transitionContext.transitionWasCancelled){
                transitionContext.completeTransition(false)
            }
            else {
                transitionContext.completeTransition(true)
            }
        })
    }
}

///
class FadeInTransitionManager : TransitionManager {
    
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
        
        // set the start location of toView depending if we're presenting or not
        toView.alpha = forward ? 0 : 1
        // add the both views to our view controller
        if forward {
            container.addSubview(fromView)
            container.addSubview(toView)
        }
        else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
        
        // get the duration of the animation
        let duration = self.transitionDuration(using: transitionContext)
        
        let options = interactive ? UIViewAnimationOptions.curveLinear : UIViewAnimationOptions.curveEaseOut
        
        self.isAnimating = true
        
        // perform the animation
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            if self.forward {
                toView.alpha = 1
            }
            else {
                fromView.alpha = 0
            }
        }, completion: { finished in
            self.isAnimating = false
            // tell our transitionContext object that we've finished animating
            if(transitionContext.transitionWasCancelled){
                transitionContext.completeTransition(false)
            }
            else {
                transitionContext.completeTransition(true)
            }
        })
    }
}
