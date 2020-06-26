//
//  BaseTabBarRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol TabProtocol {
    var rawValue: Int { get }
    init?(rawValue: Int)
}

///
protocol TabBarRouterProtocol: BaseRouterProtocol {
    associatedtype Tab: TabProtocol
    
    var viewControllers: [UIViewController]! { get set }
    func createTabViewControllers() -> [UIViewController]
}

///
extension TabBarRouterProtocol {
    
    ///
    var currentTab: Tab? {
        guard let tabBarVC = self.baseViewController as? BaseTabBarController<Tab> else { return nil }
        return Tab.init(rawValue: tabBarVC.selectedIndex)
    }
    
    ///
    var currentTabTopMostVC: UIViewController? {
        guard
            let currentTab = self.currentTab,
            currentTab.rawValue < viewControllers.count,
            let nc = viewControllers[currentTab.rawValue] as? UINavigationController
            else { return nil }
        return nc.viewControllers.last
    }
    
    ///
    var currentTabRootVC: UIViewController? {
        guard
            let currentTab = self.currentTab,
            currentTab.rawValue < viewControllers.count,
            let nc = viewControllers[currentTab.rawValue] as? UINavigationController
            else { return nil }
        return nc.viewControllers.first
    }
    
    /**
     */
    func push(vc: UIViewController, to tab: Tab, animated: Bool = true) {
        guard
            let navigationController = rootNavigationController(of: tab),
            let visibleViewController = navigationController.visibleViewController, vc != visibleViewController
            else {
                DDLogWarn(context: .navt, message: "navigation_failed", params: [ "file" : #file, "function" : #function, "reason" : "no navigation controller"])
                return
        }
        navigationController.pushViewController(vc, animated: animated)
    }
    
    /**
     */
    func insert(vc: UIViewController, to tab: Tab, at index: Int) {
        guard index >= 0 else { return }
        guard let navigationController = rootNavigationController(of: tab) else {
            DDLogWarn(context: .navt, message: "navigation_failed", params: [ "file" : #file, "function" : #function, "reason" : "no navigation controller"])
            return
        }
        let indexToInsertAt = min(navigationController.viewControllers.count, index)
        navigationController.viewControllers.insert(vc, at: indexToInsertAt)
    }
    
    /**
     */
    func append(vc: UIViewController, to tab: Tab) {
        guard let navigationController = rootNavigationController(of: tab) else {
            DDLogWarn(context: .navt, message: "navigation_failed", params: [ "file" : #file, "function" : #function, "reason" : "no navigation controller"])
            return
        }
        self.insert(vc: vc, to: tab, at: navigationController.viewControllers.count)
    }
    
    /**
     */
    func pop(tab: Tab, to vc: UIViewController) {
        guard let navigationController = rootNavigationController(of: tab) else {
            DDLogWarn(context: .navt, message: "navigation_failed", params: [ "file" : #file, "function" : #function, "reason" : "no navigation controller"])
            return
        }
        guard navigationController.viewControllers.contains(vc) else { return }
        navigationController.popToViewController(vc, animated: true)
    }
    
    /**
     */
    func popToRoot(tab: Tab) {
        rootNavigationController(of: tab)?.popToRootViewController(animated: true)
    }
    
    /**
     */
    func switchToTab(_ tab: Tab) {
        guard
            let tabBarVC = self.baseViewController as? BaseTabBarController<Tab>,
            tab.rawValue < viewControllers.count
            else {
                return
        }
        tabBarVC.selectedIndex = tab.rawValue
    }
    
    /**
     */
    private func rootNavigationController(of tab: Tab) -> UINavigationController? {
        let tabIndex = tab.rawValue
        guard
            let tabBarController = self.baseViewController as? BaseTabBarController<Tab>,
            tabIndex < (tabBarController.viewControllers ?? []).count,
            let navigationController = tabBarController.viewControllers?[tabIndex] as? UINavigationController
            else {
                return nil
        }
        return navigationController
    }
    
    /**
     */
    func toggleTabBar(show: Bool) {
        guard let tabBarController = self.baseViewController as? BaseTabBarController<Tab> else { return }
        tabBarController.tabBar.isHidden = !show
    }
}

///
class TabBarRouter<TabType: TabProtocol>: BaseRouter, TabBarRouterProtocol {
    
    var viewControllers: [UIViewController]! = []
    
    typealias Tab = TabType
    
    required init(viewController: UIViewController) {
        super.init(viewController: viewController)
        baseViewController = viewController
        guard let tabBarVC = viewController as? BaseTabBarController<Tab> else {
            DDLogError(context: .evna, message: "class_misuse", params: ["error" : "viewController for this router must be of BaseTabBarController type"], error: nil)
            return
        }
        self.viewControllers = createTabViewControllers()
        tabBarVC.setViewControllers(self.viewControllers, animated: false)
        tabBarVC.currentViewController = viewControllers.first!
    }
    
    func createTabViewControllers() -> [UIViewController] {
        return []
    }
    
    func updateTabBarController(at index: Int) {
        guard let tabBarVC = baseViewController as? BaseTabBarController<Tab> else {
            DDLogError(context: .evna, message: "class_misuse", params: ["error" : "viewController for this router must be of BaseTabBarController type"], error: nil)
            return
        }
        let newViewCotnrollers = createTabViewControllers()
        guard
            index < (tabBarVC.viewControllers ?? []).count,
            index < newViewCotnrollers.count
            else { return }
        tabBarVC.viewControllers?[index] = newViewCotnrollers[index]
    }
}
