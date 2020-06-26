//
//  AlertPresentableRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 23/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
@objc protocol AlertPresentableRouterProtocol: BaseRouterProtocol {}

///
extension AlertPresentableRouterProtocol {
    
    /**
     */
    func askManualPermissionViaSettings(title: String, message: String, onCancelTap: (() -> Void)? = nil, onSettingsTap: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = Color.cherry
        alert.addAction(UIAlertAction(title: L10n.Common.Common.Button.cancel, style: .cancel, handler: { _ in
            onCancelTap?()
        }))
        let goToSettingsAction = UIAlertAction(title: L10n.Common.Common.Button.settings, style: .default, handler: { action in
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
            onSettingsTap?()
        })
        alert.addAction(goToSettingsAction)
        alert.preferredAction = goToSettingsAction
        if let presentedVC = baseViewController?.presentedViewController {
            presentedVC.dismiss(animated: true, completion: {
                self.baseViewController?.present(alert, animated: true, completion: nil)
            })
        }
        else {
            baseViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
