//
//  CommonNavigationController.swift
//  BaseMVVMExample
//
//  Created by Admin on 06/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class CommonNavigationController: CustomTransitioningNavigationController {
   
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        navigationBar.titleTextAttributes = [
            .foregroundColor: Color.black,
            .font : Font.semibold17
        ]
        navigationBar.tintColor = Color.cherry
        navigationBar.isTranslucent = !iOS10
        navigationBar.barTintColor = Color.white
        navigationBar.shadowImage = UIImage()
        if iOS10 {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        navigationBar.backIndicatorTransitionMaskImage = Asset.NavBar.backButton.image
        navigationBar.backIndicatorImage = Asset.NavBar.backButton.image
    }
    
    /**
     */
    func changeTitleAttributes(attributes: [NSAttributedStringKey : Any]) {
        navigationBar.titleTextAttributes = attributes
    }
}

///
extension UINavigationController {
    
    ///
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
