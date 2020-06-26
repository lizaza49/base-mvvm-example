//
//  UIViewController+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
extension UIViewController {
    
    ///
    static var topMost: UIViewController? {
        return topMost(in: UIApplication.shared.keyWindow?.rootViewController)
    }
    
    /**
     */
    private static func topMost(in vc: UIViewController?) -> UIViewController? {
        guard var topController = vc else { return nil }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        if let nc = topController as? UINavigationController {
            return topMost(in: nc.viewControllers.last)
        }
        else if let tabBarController = topController as? UITabBarController {
            let tabs = tabBarController.viewControllers ?? []
            guard !tabs.isEmpty, tabBarController.selectedIndex < tabs.count else { return tabBarController }
            return topMost(in: tabs[tabBarController.selectedIndex])
        }
        return topController
    }
    
    ///
    var topBarHeight: CGFloat {
        let shouldConsiderNavBar = (self as? NavigationBarToggleable)?.hasNavigationBar ?? false
        var navBarHeight: CGFloat = 0
        if shouldConsiderNavBar {
            navBarHeight = (self.navigationController?.navigationBar.frame.height ?? 0)
        }
        return UIApplication.shared.statusBarFrame.height + navBarHeight
    }
    
    ///
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 50
    }
    
    /**
     */
    static func swizzle() {
        let orginalSelectors = [#selector(viewDidLoad), #selector(show(_:sender:))]
        let swizzledSelectors = [#selector(swizzledViewDidLoad), #selector(swizzledShow(_:sender:))]
        
        let orginalMethods = orginalSelectors.map { class_getInstanceMethod(UIViewController.self, $0) }
        let swizzledMethods = swizzledSelectors.map { class_getInstanceMethod(UIViewController.self, $0) }
        
        orginalSelectors.enumerated().forEach { item in
            let didAddMethod = class_addMethod(
                UIViewController.self,
                item.element,
                method_getImplementation(swizzledMethods[item.offset]!),
                method_getTypeEncoding(swizzledMethods[item.offset]!))
            
            if didAddMethod {
                class_replaceMethod(
                    UIViewController.self,
                    swizzledSelectors[item.offset],
                    method_getImplementation(orginalMethods[item.offset]!),
                    method_getTypeEncoding(orginalMethods[item.offset]!))
            } else {
                method_exchangeImplementations(orginalMethods[item.offset]!, swizzledMethods[item.offset]!)
            }
        }
    }
    
    /**
     */
    @objc func swizzledViewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        swizzledViewDidLoad()
    }
    
    /**
     */
    @objc func swizzledShow(_ vc: UIViewController, sender: Any?) {
        let nc = self.navigationController ?? (self as? UINavigationController)
        if let customTransitioningNC = nc as? CustomTransitioningNavigationController {
            customTransitioningNC.pushViewController(vc, animated: true, sender: sender)
        }
        else if let nc = nc {
            nc.pushViewController(vc, animated: true)
        }
        else {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    /**
     */
    func add(childVC: UIViewController, to view: UIView) {
        childVC.view.frame = view.bounds
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParentViewController: self)
        childVC.view.snp.makeConstraints({ make in
            make.width.height.centerX.centerY.equalToSuperview()
        })
    }
	
	func remove(childVC: UIViewController?) {
		guard let childVC = childVC else { return }
		childVC.willMove(toParentViewController: nil)
		childVC.view.removeFromSuperview()
		childVC.removeFromParentViewController()
	}
	
    /**
     */
    func removeFromParent() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    /**
     */
    @objc func addBackButton() {
        let backButton = UIBarButtonItem(image: Asset.NavBar.backButton.image, style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
    }
    
    /**
     */
    @objc private func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     */
    func presentDevelopmentAlert() {
        let alert = UIAlertController(title: "Внимание!", message: "Данный раздел находится в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
