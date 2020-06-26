//
//  CustomTransitioningNavigationController.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
@objc protocol NavigationControllerInteractiveTransitionDelegate: class {
    @objc optional var allowsInteractivePop: Bool { get }
    @objc optional func navigationController(_ navigationController: UINavigationController, interactiveOperation: UINavigationControllerOperation, didComplete: Bool)
    @objc optional func navigationController(_ navigationController: UINavigationController, performs interactiveOperation: UINavigationControllerOperation, withProgress progress: CGFloat)
}

///
protocol NavigationBarToggleable {
    var hasNavigationBar: Bool { get }
}

///
class CustomTransitioningNavigationController : UINavigationController, CustomTransitioningProtocol {
    
    ///
    var interactive: Bool = false
    weak var interactiveTransitionDelegate: NavigationControllerInteractiveTransitionDelegate?
    
    /**
     */
    private var _transitionManager: TransitionManager? = nil
    var transitionManager: TransitionManager? {
        get {
            return _transitionManager
        }
        set {
            self._transitionManager = newValue
        }
    }
    
    private var interactiveTransitionManager: TransitionManager? = nil
    private var popGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        transitionManager = nil
        self.transitioningDelegate = transitionManager
        interactivePopGestureRecognizer?.delegate = self
        popGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.screenEdgePanAction(_:)))
        popGestureRecognizer.edges = .left
        popGestureRecognizer.delegate = self
        view.addGestureRecognizer(popGestureRecognizer)
    }
    
    /**
     */
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        let transitionManager = (self.viewControllers.last as? CustomTransitioningProtocol)?.transitionManager(for: .backwards) ?? self.transitionManager
        guard !(transitionManager?.isAnimating ?? false) else { return nil }
        
        let vcCount = self.viewControllers.count
        guard vcCount > 0 else { return super.popViewController(animated: animated) }
        transitionManager?.forward = false
        self.transitioningDelegate = transitionManager
        return super.popViewController(animated: animated)
    }
    
    /**
     */
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let vcCount = self.viewControllers.count
        guard vcCount > 0 else { return super.popToRootViewController(animated: animated) }
        let transitionManager = (self.viewControllers.last as? CustomTransitioningProtocol)?.transitionManager ?? self.transitionManager
        transitionManager?.forward = false
        self.transitioningDelegate = transitionManager
        return super.popToRootViewController(animated: animated)
    }
    
    /**
     */
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        push(viewController: viewController, animated: animated, transitionManager: nil)
    }
    
    /**
     This function's purpose is to check sender argument and create a corresponding transitionManager
     */
    func pushViewController(_ viewController: UIViewController, animated: Bool, sender: Any?) {
        push(viewController: viewController, animated: animated, transitionManager: nil)
    }
    
    /**
     */
    private func push(viewController: UIViewController, animated: Bool, transitionManager: TransitionManager?) {
        guard !viewControllers.contains(viewController) else {
            DDLogError(context: .evna, message: "Attempt to push a \(viewController.classForCoder) to a navigation stack which already contains it", params: [ "file" : #file, "function" : #function ], error: nil)
            return
        }
        let customTransitioningVC = viewController as? CustomTransitioningProtocol
        let transitionManager = transitionManager ??
            customTransitioningVC?.transitionManager(for: .forward) ??
            self.transitionManager
        transitionManager?.forward = true
        self.transitioningDelegate = transitionManager
        super.pushViewController(viewController, animated: animated)
    }
    
    /**
     */
    @discardableResult
    private func plainPop(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
}

///
extension CustomTransitioningNavigationController : UINavigationControllerDelegate {
    
    /**
     */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let transitionManager = self.transitioningDelegate as? TransitionManager else {
            return nil
        }
        transitionManager.forward = operation == .push
        return transitionManager
    }
    
    /**
     */
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactiveTransitionManager : nil
    }
}

/// Interactive pop
extension CustomTransitioningNavigationController: UIGestureRecognizerDelegate {
    
    /**
     */
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let interactiveTransitionDelegate = (self.viewControllers.last as? NavigationControllerInteractiveTransitionDelegate) ?? self.interactiveTransitionDelegate
        let interactivePopIsAllowed = interactiveTransitionDelegate?.allowsInteractivePop ?? true
        if interactivePopIsAllowed && interactiveTransitionManager == nil {
            interactiveTransitionManager = (viewControllers.last as? CustomTransitioningProtocol)?.transitionManager ?? self.transitionManager
        }
        else if interactiveTransitionManager == nil && gestureRecognizer != popGestureRecognizer {
            return (self.viewControllers.count > 1)
        }
        return interactivePopIsAllowed && (self.viewControllers.count > 1)
    }
    
    /**
     */
    @objc func screenEdgePanAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        let vX = sender.velocity(in: self.view).x
        let tX = sender.translation(in: self.view).x
        let progress: CGFloat = tX / self.view.frame.width
        
        guard let interactiveTransitionManager = self.interactiveTransitionManager ?? self.transitionManager else { return }
        
        switch sender.state {
        case .began:
            interactive = true
            interactiveTransitionManager.interactive = true
            interactiveTransitionManager.forward = false
            self.transitioningDelegate = interactiveTransitionManager
            plainPop(animated: true)
            interactiveTransitionManager.update(progress)
            interactiveTransitionDelegate?.navigationController?(self, performs: .pop, withProgress: progress)
            break
            
        case .changed:
            interactiveTransitionManager.update(progress)
            interactiveTransitionDelegate?.navigationController?(self, performs: .pop, withProgress: progress)
            break
            
        case .cancelled, .failed:
            interactiveTransitionManager.cancel()
            interactive = false
            interactiveTransitionManager.interactive = false
            interactiveTransitionDelegate?.navigationController?(self, interactiveOperation: .pop, didComplete: false)
            break
            
        case .ended:
            let velocityIsWeak = (-0.2 ... 0.2) ~= vX
            if (velocityIsWeak && progress > 0.5) || vX > 0.2 {
                interactiveTransitionManager.finish()
                interactiveTransitionDelegate?.navigationController?(self, interactiveOperation: .pop, didComplete: true)
            }
            else {
                interactiveTransitionManager.cancel()
                interactiveTransitionDelegate?.navigationController?(self, interactiveOperation: .pop, didComplete: false)
            }
            interactive = false
            interactiveTransitionManager.interactive = false
            
        default:
            break
        }
    }
}
