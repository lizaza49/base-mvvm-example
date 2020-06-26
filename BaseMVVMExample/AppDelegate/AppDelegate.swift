//
//  AppDelegate.swift
//  BaseMVVMExample
//
//  Created by Admin on 27/02/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()
    lazy var viewModel: AppDelegateViewModelProtocol = {
        let router = AppDelegateRouter(window: window!)
        return AppDelegateViewModel(router: router)
    }()

    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.makeKeyAndVisible()
        viewModel.onFinishLaunching(with: launchOptions)
        return true
    }
}
