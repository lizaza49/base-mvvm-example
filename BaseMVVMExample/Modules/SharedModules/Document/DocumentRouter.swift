//
//  DocumentDocumentRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 16/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit

///
protocol DocumentRouterProtocol: BaseRouterProtocol {}

extension DocumentRouterProtocol {
    
    /**
     */
    func share(fileAt url: URL) {
        let activityVC = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
        baseViewController?.present(activityVC, animated: true, completion: nil)
    }
}

///
final class DocumentRouter: BaseRouter, DocumentRouterProtocol {}
