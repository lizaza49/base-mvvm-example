//
//  InitialFlowTransitionManager.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class InitialFlowTransitionManager : TransitionManager {
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    // perform the animation(s) to show the transition from one screen to another
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to the container view that we should perform the transition in
        let container = transitionContext.containerView
        
        // get references to our 'from' and 'to' view controllers
        guard
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UIViewController & InitialFlowViewControllerProtocol,
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UIViewController & InitialFlowViewControllerProtocol
        else {
            FadeInTransitionManager().animateTransition(using: transitionContext)
            return
        }
        
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
        
        // Manage logo
        let fromViewHeightDiff = GlobalUIConstants.screenHeight - fromView.bounds.height
        let toViewHeightDiff = GlobalUIConstants.screenHeight - toView.bounds.height
        let fromLogoTopInset = fromViewController.topBarHeight + fromViewController.logoTopInset - fromViewHeightDiff
        let toLogoTopInset = toViewController.topBarHeight + toViewController.logoTopInset - toViewHeightDiff
        
        let logoImageView = UIImageView(image: Asset.Logo.logo.image)
        logoImageView.contentMode = .scaleAspectFill
        container.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(fromLogoTopInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(GlobalUIConstants.Logo.size)
        }
        fromViewController.logoImageView.alpha = 0
        toViewController.logoImageView.alpha = 0
        
        // get the duration of the animation
        let duration = transitionDuration(using: transitionContext)
        
        self.isAnimating = true
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                fromView.alpha = 0
                fromView.transform = self.forward ? leftTransform : rightTransform
                logoImageView.transform = CGAffineTransform(translationX: 0, y: (toLogoTopInset - fromLogoTopInset)/2)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                toView.alpha = 1
                toView.transform = .identity
                logoImageView.transform = CGAffineTransform(translationX: 0, y: toLogoTopInset - fromLogoTopInset)
            })
        }, completion: { finished in
            self.isAnimating = false
            fromView.transform = .identity
            toView.transform = .identity
            // tell our transitionContext object that we've finished animating
            if transitionContext.transitionWasCancelled {
                fromView.transform = .identity
                toView.transform = self.forward ? rightTransform : leftTransform
                fromViewController.logoImageView.alpha = 1
                fromView.alpha = 1
                toView.alpha = 0
                transitionContext.completeTransition(false)
            }
            else {
                fromView.transform = .identity
                toView.transform = .identity
                fromView.alpha = 1
                toView.alpha = 1
                toViewController.logoImageView.alpha = 1
                transitionContext.completeTransition(true)
            }
            logoImageView.removeFromSuperview()
        })
    }
}
