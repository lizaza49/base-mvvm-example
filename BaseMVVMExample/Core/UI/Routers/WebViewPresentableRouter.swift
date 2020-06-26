//
//  WebViewPresentableRouter.swift
//  BaseMVVMExample
//
//  Created by Admin on 08/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
enum WebViewTargetMode {
    case local // for inner domain
    case global // all th other domains
}

///
protocol WebViewPresentableRouterProtocol: BaseRouterProtocol {}

///
extension WebViewPresentableRouterProtocol {
    
    func present(url: URL, mode: WebViewTargetMode, title: String) {
        do {
            var urlRequest = try URLRequest(url: url, method: .get)
            switch mode {
            case .local:
                Constants.WebView.localHeaders.forEach {
                    urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
                }
                break
            default:
                break
            }
            let webViewController = WebViewController(url: urlRequest)
            webViewController.navigationItem.title = title
            show(viewController: webViewController)
        }
        catch {
            present(error: error)
        }
    }
}
