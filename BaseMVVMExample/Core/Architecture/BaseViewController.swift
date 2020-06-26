//
//  BaseViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 04/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol BaseViewControllerProtocol: NavigationBarToggleable {
    var navBarIsUnderlined: Bool { get }
}

///
class BaseViewController: UIViewController, BaseViewControllerProtocol {

    var hasNavigationBar: Bool {
        return true
    }
    var navBarIsUnderlined: Bool {
        return true
    }
    
    private var prevNavBarShadowImage: UIImage?
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
    }

    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prevNavBarShadowImage = navigationController?.navigationBar.shadowImage
        updateNavigationBar(animated)
    }
    
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Navigation bar management
    
    /**
     */
    func updateNavigationBar(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(!hasNavigationBar, animated: animated)
        adjustNavBarShadowImage(image: navBarIsUnderlined ? nil : UIImage(), animated)
    }
    
    /**
     */
    private func adjustNavBarShadowImage(image: UIImage?, _ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { return }
        let animatableUpdates: (() -> Void) = {
            navBar.shadowImage = image
        }
        if animated {
            let animation = CATransition()
            animation.duration = 0.3
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            navBar.layer.add(animation, forKey: nil)
            UIView.animate(withDuration: 0.3, animations: animatableUpdates)
        }
        else {
            animatableUpdates()
        }
    }
}
