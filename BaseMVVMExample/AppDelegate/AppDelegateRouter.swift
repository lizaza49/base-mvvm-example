//
//  AppDelegateRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol AppDelegateRouterProtocol {
    func playLaunchAnimation(shouldPlayAnimation: Bool, completion: @escaping () -> Void)
    func presentOnBoarding()
    func presentDashboard()
    
    func pushToRoot(_ vc: UIViewController)
}

///
final class AppDelegateRouter: AppDelegateRouterProtocol {

    ///
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    ///
    static var shared: AppDelegateRouterProtocol {
        return (UIApplication.shared.delegate as? AppDelegate)!.viewModel.router
    }
    
    /**
     */
    func playLaunchAnimation(shouldPlayAnimation: Bool = true, completion: @escaping () -> Void) {
        let launchVCAnimate = LaunchAnimationViewController()
        launchVCAnimate.shouldPlayAnimation = shouldPlayAnimation
        launchVCAnimate.animationPlaybackDidEnd = completion
        setRootViewController(with: launchVCAnimate)
    }
    
    /**
     */
    func presentOnBoarding() {
        let vc = OnBoardViewController()
        OnBoardModuleConfigurator.configure(with: vc)
        pushToRoot(vc)
    }
    
    /**
     */
    func presentDashboard() {
        guard let tabBarVC = MainTabBarRouter.shared.baseViewController else { return }
        pushToRoot(tabBarVC)
    }
    
    /**
     */
    private func setRootViewController(with vc: UIViewController) {
        let navigationController = CommonNavigationController(rootViewController: vc)
        window.rootViewController = navigationController
    }
    
    /**
     */
    func pushToRoot(_ vc: UIViewController) {
        (window.rootViewController as? UINavigationController)?.pushViewController(vc, animated: true)
    }
}
