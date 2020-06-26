//
//  BaseTabBarController.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class BaseTabBarController<Tab: TabProtocol>: UITabBarController, CustomTransitioningProtocol {
    
    var transitionManager: TransitionManager? = CrossDissolveTransitionManager()
    var interactive: Bool = false
    
    var currentTab: Tab? {
        didSet {
            guard let currentTab = currentTab, let oldValue = oldValue else { return }
            onTabSelect(newTab: currentTab, oldTab: oldValue)
        }
    }
    
    var currentViewController: UIViewController?
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return currentViewController
    }
    
    override var selectedIndex: Int {
        get { return super.selectedIndex }
        set {
            super.selectedIndex = newValue
            selectedTabDidChange(newValue)
        }
    }
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        setupTabBar()
    }
    
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    /**
     */
    private func setupTabBar() {
        tabBar.isTranslucent = false
        tabBar.barTintColor = Color.white
        tabBar.shadowImage = UIImage()
    }
    
    /**
     */
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedIndex = tabBar.items?.index(of: item),
            selectedIndex < (viewControllers ?? []).count
            else { return }
        selectedTabDidChange(selectedIndex)
    }
    
    /**
     */
    private func selectedTabDidChange(_ selectedIndex: Int) {
        self.currentViewController = self.viewControllers?[selectedIndex]
        self.currentTab = Tab(rawValue: selectedIndex)
    }
    
    /**
     */
    private func onTabSelect(newTab: TabProtocol, oldTab: TabProtocol) {
        
    }
}
