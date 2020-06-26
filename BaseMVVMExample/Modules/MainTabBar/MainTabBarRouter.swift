//
//  MainTabBarRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

fileprivate typealias TabTitle = L10n.Common.Tabbar.Title

///
enum MainTab: Int, TabProtocol {
    case dashboard = 0, policies, purchase, offices, profile
    
    static var all: [MainTab] {
        return Array(0 ... 4).compactMap { MainTab(rawValue: $0) }
    }
    
    var title: String {
        switch self {
        case .dashboard: return TabTitle.main
        case .policies: return TabTitle.policies
        case .purchase: return TabTitle.purchase
        case .offices: return TabTitle.offices
        case .profile: return TabTitle.profile
        }
    }
}

///
protocol MainTabBarRouterProtocol: TabBarRouterProtocol {
    func updateTabItemImage(_ imageURL: URL, at tab: Tab)
}

///
class MainTabBarRouter: TabBarRouter<MainTab>, MainTabBarRouterProtocol {
    
    private static var instance: MainTabBarRouter!
    static var shared: MainTabBarRouter {
        if instance == nil {
            let vc = BaseTabBarController<Tab>()
            vc.tabBar.tintColor = Color.cherry
            vc.tabBar.unselectedItemTintColor = Color.lightGray
            instance = MainTabBarRouter(viewController: vc)
        }
        return instance
    }
    
    ///
    static var isActive: Bool {
        return instance != nil
    }
    
    override func createTabViewControllers() -> [UIViewController] {
        return [
            dashboardNavController(),
            policiesNavController(),
            purchasesNavController(),
            officesNavController(),
            profileNavController()
        ]
    }
    
    /**
     */
    private func dashboardNavController() -> CommonNavigationController {
        let vc = DashboardViewController()
        DashboardModuleConfigurator.configure(with: vc)
        vc.tabBarItem.title = TabTitle.main
        vc.tabBarItem.image = Asset.Tabbar.tabHome.image
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.lightGray], for: .normal)
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.cherry], for: .selected)
        return CommonNavigationController(rootViewController: vc)
    }

    /**
     */
    private func policiesNavController() -> CommonNavigationController {
        let vc = PoliciesViewController()
        PoliciesModuleConfigurator.configure(with: vc)
        vc.tabBarItem.title = TabTitle.policies
        vc.tabBarItem.image = Asset.Tabbar.tabPolicies.image
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.lightGray], for: .normal)
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.cherry], for: .selected)
        return CommonNavigationController(rootViewController: vc)
    }
    
    /**
     */
    private func purchasesNavController() -> CommonNavigationController {
        let vc = PurchasesViewController()
        PurchasesModuleConfigurator.configure(with: vc)
        vc.tabBarItem.title = TabTitle.purchase
        vc.tabBarItem.image = Asset.Tabbar.tabPurchases.image
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.lightGray], for: .normal)
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.cherry], for: .selected)
        return CommonNavigationController(rootViewController: vc)
    }
    
    /**
     */
    private func officesNavController() -> CommonNavigationController {
		
		let vc = OfficiesWrapperViewController()
		OfficiesWrapperModuleConfigurator.configure(with: vc, displayStyle: .normal)
		
        vc.tabBarItem.title = TabTitle.offices
        vc.tabBarItem.image = Asset.Tabbar.tabOffices.image
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.lightGray], for: .normal)
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.cherry], for: .selected)
        return CommonNavigationController(rootViewController: vc)
    }
    
    /**
     */
    private func profileNavController() -> CommonNavigationController {
        let vc = ProfileViewController()
        ProfileModuleConfigurator.configure(with: vc)
        vc.tabBarItem.title = TabTitle.profile
        vc.tabBarItem.image = Asset.Tabbar.tabProfile.image
        if let userThumbnailURL = User.shared.photoThumbnailURL {
            updateTabItemImage(userThumbnailURL, at: MainTab.profile)
        }
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.lightGray], for: .normal)
        vc.tabBarItem.setTitleTextAttributes([.foregroundColor: Color.cherry], for: .selected)
        return CommonNavigationController(rootViewController: vc)
    }
    
    // MARK: - Public functions
    
    /**
     */
    func reset() { MainTabBarRouter.instance = nil }
    
    /**
     TODO: Subscribe User object updates to update tabBarItem image on URL update
     */
    func updateTabItemImage(_ imageURL: URL, at tab: Tab) {
        SDWebImageManager.shared().loadImage(with: imageURL, options: [], progress: nil) { (image, _, _, _, _, _) in
            guard let image = image else { return }
            let iconView = MainTabBarProfileIconView(image: image)
            if let snapshot = iconView.snapshot(),
                let scaledImage = UIImage.scale(image: snapshot, by: 1.0/UIScreen.main.scale) {
                self.setTabItemImage(scaledImage, at: tab)
            }
        }
    }
    
    /**
     */
    private func setTabItemImage(_ image: UIImage, at tab: Tab) {
        guard (0 ..< viewControllers.count) ~= tab.rawValue else { return }
        let tabBarItem = viewControllers[tab.rawValue].tabBarItem
        tabBarItem?.image = image.withRenderingMode(.alwaysOriginal)
        tabBarItem?.selectedImage = image.withRenderingMode(.alwaysOriginal)
        tabBarItem?.title = tab.title
    }
}
