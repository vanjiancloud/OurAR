//
//  ThreeDModelController.swift
//  OurAR
//
//  Created by lee on 2023/8/18.
//

import Foundation
import UIKit
import WebKit
import CloudAR

protocol ThreeDURLProtocol
{
    func handleLoadThreeDURL()
}

class ThreedModelController: UIViewController,WKNavigationDelegate,ThreeDURLProtocol, WKUIDelegate
{
    var webView: WKWebView!
    
    deinit {
        print("-----ThreedModelController - deinit")
    }
    
    override func viewDidLoad() {
        self.view = ThreeDModelView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        // 创建 WKWebView 实例
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        //webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isUserInteractionEnabled = true
        self.view.addSubview(webView)
        
        // 设置约束，这里使用 AutoLayout 进行布局
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    // 如果需要在加载完成后执行操作，可以使用 WKNavigationDelegate 方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 网页加载完成后的操作
        print("网页加载完成")
    }

    func handleLoadThreeDURL() {
        if let url = URL(string: car_UserInfo.threeDURL) {
            print("handle load threeD url")
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
