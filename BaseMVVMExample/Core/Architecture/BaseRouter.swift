//
//  BaseRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
@objc protocol BaseRouterProtocol: class {
    var baseViewController: UIViewController? { get set }
    
    init(viewController: UIViewController)
}

// MARK: - Base presentation functions for info / errors

///
extension BaseRouterProtocol {
    
    /**
     Takes error and decides which action to perform
     */
    func present(error: Error) {
        presentBanner(error: error)
    }
}

// MARK: - Functions for particular error styles presentation

///
extension BaseRouterProtocol {
    
    /**
     */
    func presentBanner(error: Error) {
        guard let vc = baseViewController else { return }
        let bannerViewModel = TopBannerViewModel.error(text: error.localizedDescription)
        let bannerView = TopBannerView()
        bannerView.configure(with: bannerViewModel, superviewSize: vc.view.frame.size)
        
        vc.view.addSubview(bannerView)
        bannerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(vc.view.snp.topMargin)
            make.height.equalTo(bannerView.frame.height)
        }
        bannerView.show()
    }
}

// MARK: - Navigation functions

///
extension BaseRouterProtocol {
    
    /**
     */
    func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let nc = baseViewController?.navigationController {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            nc.popViewController(animated: true)
            CATransaction.commit()
        }
        else if baseViewController?.presentingViewController != nil {
            baseViewController?.dismiss(animated: true, completion: completion)
        }
    }
    
    /**
     */
    func pop<T: UIViewController>(toTopVcOfType type: T.Type, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let nc = baseViewController?.navigationController else { return }
        guard let targetVC = nc.viewControllers.reversed().compactMap({ $0 as? T }).first else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        nc.popToViewController(targetVC, animated: animated)
        CATransaction.commit()
    }
    
    /**
     */
    func popToRoot(animated: Bool = true) {
        baseViewController?.navigationController?.popToRootViewController(animated: animated)
    }
    
    /**
     */
    func show(viewController: UIViewController, sender: Any? = nil, completion: (() -> Void)? = nil) {
        if let navigationController = baseViewController?.navigationController {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            navigationController.pushViewController(viewController, animated: true)
            CATransaction.commit()
        }
        else {
            baseViewController?.present(viewController, animated: true, completion: completion)
        }
    }
    
    /**
     */
    func presentDevelopmentAlert() {
        baseViewController?.presentDevelopmentAlert()
    }
}

///
class BaseRouter: NSObject, BaseRouterProtocol {
    var baseViewController: UIViewController?
    
    required init (viewController: UIViewController) {
        baseViewController = viewController
    }
}
