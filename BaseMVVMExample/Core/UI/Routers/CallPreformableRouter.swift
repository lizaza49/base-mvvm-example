//
//  CallPreformableRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 03/05/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol CallPreformableRouterProtocol: BaseRouterProtocol {}

///
extension CallPreformableRouterProtocol {
    
    private var callUrlPattern: String {
        return "tel://%@"
    }
    
    /**
     */
    func call(to phone: String) {
        guard let url = URL(string: String.init(format: callUrlPattern, phone)) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
