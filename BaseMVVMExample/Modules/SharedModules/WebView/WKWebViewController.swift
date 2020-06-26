//
//  WKWebViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 07/04/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire

///
protocol WKWebViewControllerDelegate: WKNavigationDelegate {
    func webViewControllerWillDismiss()
}

///
protocol WebViewControllerDelegate: class {
    func webViewControllerDidTapDone(_ webVC: WebViewController)
}

///
class WKWebViewController: UIViewController {
    
    private lazy var containerView = UIView()
    private let webVC: WebViewControllerProtocol & UIViewController
    weak var delegate: WKWebViewControllerDelegate?
    
    /**
     */
    init(webViewController: WebViewControllerProtocol & UIViewController,
         delegate: WKWebViewControllerDelegate? = nil,
         title: String? = nil) {
        self.webVC = webViewController
        webVC.title = title
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = Color.white
        assignDelegate(delegate)
    }
    
    /**
     */
    init(url: URL,
         delegate: WKWebViewControllerDelegate?,
         title: String? = nil) {
        self.webVC = WebViewController(url: url, navigationDelegate: delegate)
        webVC.title = title
        super.init(nibName: nil, bundle: nil)
        assignDelegate(delegate)
    }
    
    /**
     */
    private func assignDelegate(_ delegate: WKWebViewControllerDelegate?) {
        webVC.delegate = self
        self.delegate = delegate
    }
    
    /**
     */
    required init?(coder aDecoder: NSCoder) {
        let err = "init(coder:) has not been implemented"
        DDLogError(context: .evna, message: "class_misuse", params: [ "file" : #file, "function" : #function, "error" : err ], error: nil)
        fatalError(err)
    }
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let navigationController = UINavigationController(rootViewController: self.webVC)
        self.add(childVC: navigationController, to: self.containerView)
    }
    
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

///
extension WKWebViewController: WebViewControllerDelegate {
    
    func webViewControllerDidTapDone(_ webVC: WebViewController) {
        delegate?.webViewControllerWillDismiss()
        self.dismiss(animated: true, completion: nil)
    }
}

///
protocol WebViewControllerProtocol: class {
    var webView: WKWebView! { get }
    var navigationDelegate: WKNavigationDelegate? { get set }
    var delegate: WebViewControllerDelegate? { get set }
}

///
class WebViewController: UIViewController, WebViewControllerProtocol {
    
    ///
    var webView: WKWebView!
    weak var navigationDelegate: WKNavigationDelegate?
    weak var delegate: WebViewControllerDelegate?
    var initialUrlRequest: URLRequest?
    
    ///
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = Color.loaderGray
        return activityIndicatorView
    }()
    
    ///
    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set {}
    }
    
    /**
     */
    init(url: URLRequestConvertible? = nil, navigationDelegate: WKNavigationDelegate? = nil) {
        self.initialUrlRequest = url?.urlRequest
        self.navigationDelegate = navigationDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     */
    required init?(coder aDecoder: NSCoder) {
        let err = "init(coder:) has not been implemented"
        DDLogError(context: .evna, message: "class_misuse", params: [ "file" : #file, "function" : #function, "error" : err ], error: nil)
        fatalError(err)
    }
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        createWKWebView()
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin)
            make.left.right.bottom.equalToSuperview()
        }
        
        activityIndicator.backgroundColor = UIConstants.activityIndicatorBg
        activityIndicator.layer.cornerRadius = UIConstants.activityIndicatorCornerRadius
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(UIConstants.activityIndicatorSize)
        }
        
        loadContent()
    }
    
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     */
    func createWKWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = navigationDelegate ?? self
    }
    
    /**
     */
    func loadContent() {
        if let initialUrlRequest = self.initialUrlRequest {
            webView.load(initialUrlRequest)
        }
    }
    
    /**
     */
    @objc private func doneTap() {
        self.delegate?.webViewControllerDidTapDone(self)
    }
}

///
extension WebViewController: WKNavigationDelegate {
    
    /**
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        activityIndicator.startAnimating()
        decisionHandler(.allow)
    }
    
    /**
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
}

///
extension WebViewController {
    struct UIConstants {
        static let activityIndicatorSize = CGSize(width: 65, height: 65)
        static let activityIndicatorBg = Color.shadeOfGray
        static let activityIndicatorCornerRadius: CGFloat = 5
    }
}
