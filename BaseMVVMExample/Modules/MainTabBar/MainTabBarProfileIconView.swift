//
//  MainTabBarProfileIconView.swift
//  BaseMVVMExample
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
class MainTabBarProfileIconView: UIView {
    private let imageView = UIImageView()
    
    init(image: UIImage) {
        super.init(frame: CGRect(origin: .zero, size: UIConstants.iconSize))
        imageView.frame = CGRect(origin: .zero, size: UIConstants.iconSize)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = UIConstants.iconSize.width/2
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        let err = "init(coder:) has not been implemented"
        DDLogError(context: .evna, message: "class_misuse", params: [ "file" : #file, "function" : #function, "error" : err ], error: nil)
        fatalError(err)
    }
}

///
extension MainTabBarProfileIconView {
    struct UIConstants {
        static let iconSize = CGSize(width: 24, height: 24)
    }
}
