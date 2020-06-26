//
//  AppDelegateViewModel.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import Fabric
import Crashlytics
import Firebase
import SnapKit
import SDWebImage
import YandexMapKit

///
protocol AppDelegateViewModelProtocol {
    var router: AppDelegateRouterProtocol { get }
    func onFinishLaunching(with options: [UIApplicationLaunchOptionsKey: Any]?)
    func onAppDidBecomeActive()
}

///
final class AppDelegateViewModel: NSObject, AppDelegateViewModelProtocol {
    
    let router: AppDelegateRouterProtocol
    private lazy var keychainService: KeychainServiceProtocol = KeychainService()
    
    init(router: AppDelegateRouterProtocol) {
        self.router = router
    }
    
    /**
     */
    func onFinishLaunching(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        // Crashlytics
        #if !DEBUG
        Fabric.with([Crashlytics.self])
        #endif
		
		registerDependecies()
        
        // Firebase
        FirebaseApp.configure()
        
        configureSdWebImage()
		
		configureYandexMapKit()
        
        UIViewController.swizzle()
        
        performRouting()
    }

    /**
     */
    func onAppDidBecomeActive() {
        
    }
    
    // MARK: Private features
    
    /**
     */
    private func performRouting() {
        if let email = User.shared.email, keychainService.token(for: email) != nil {
            performRouting(playingLaunchAnimation: false) { self.router.presentDashboard() }
        }
        else {
            performRouting { self.router.presentOnBoarding() }
        }
    }
    
    /**
     */
    private func performRouting(playingLaunchAnimation: Bool = true, routingBlock: @escaping () -> Void) {
        router.playLaunchAnimation(shouldPlayAnimation: playingLaunchAnimation, completion: routingBlock)
    }
    
    /**
     */
    private func configureSdWebImage() {
        if let manager = SDWebImageManager.shared().imageDownloader {
            manager.setValue("Basic " + Constants.basicAuthToken, forHTTPHeaderField: "Authorization")
		}
	}
	
	/**
	*/
	private func configureYandexMapKit() {
		YMKMapKit.setApiKey("84e5c3ba-3b5b-4d9a-9c35-675cb183c3f5")
	}
	
	/**
	*/
	private func registerDependecies() {
		AppDependencyInjection.registerAll()
	}
}
