//
//  LaunchAnimationViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 05/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
final class LaunchAnimationViewController: UIViewController {
    
    private let logoImageView = UIImageView(image: Asset.Logo.logo.image)
    var animationPlaybackDidEnd: (() -> Void)?
    var shouldPlayAnimation: Bool = true
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(GlobalUIConstants.Logo.size)
        }
    }
    
    /**
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard shouldPlayAnimation else {
            animationPlaybackDidEnd?()
            return
        }
        logoImageView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(GlobalUIConstants.Logo.size)
            make.top.equalTo(view.snp.topMargin).offset(view.bounds.height * GlobalUIConstants.Logo.topInsetMultiplier)
        }
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.animationPlaybackDidEnd?()
        })
    }
    
    /**
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let nc = self.navigationController, nc.viewControllers.count > 1 else { return }
        nc.viewControllers.remove(at: 0)
    }
}
