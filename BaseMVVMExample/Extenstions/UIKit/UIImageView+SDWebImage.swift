//
//  UIImageView+SDWebImage.swift
//  BaseMVVMExample
//
//  Created by Admin on 16/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import SDWebImage
import UIKit

///
extension UIImageView {
    
    /**
     */
    func updateImage(url: URL?, mapper: ((UIImage) -> UIImage)? = nil, animated: Bool = false) {
        guard let url = url else {
            image = nil
            return
        }
        SDWebImageManager.shared().loadImage(
            with: url,
            options: [],
            progress: nil) { [weak self] (image, _, _, _, _, loadedUrl) in
                guard let `self` = self, url == loadedUrl, let image = image else { return }
                self.setImage(mapper?(image) ?? image, animated: animated)
        }
    }
    
    /**
     */
    private func setImage(_ image: UIImage, animated: Bool = false) {
        let animatableUpdates = {
            self.image = image
        }
        if animated {
            UIView.transition(with: self, duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: animatableUpdates,
                              completion: nil)
        }
        else {
            animatableUpdates()
        }
    }
}
