//
//  SingPassVC.swift
//  OCBCPayNow
//
//  Created by admin on 5/10/21.
//

import UIKit
import WebKit


protocol SingPassDelegate: AnyObject {
    func loadMyInforequestResutApi()
}

class SingPassVC: UIViewController {
    var webView: WKWebView!
    var url : URL?
    weak var delegate: SingPassDelegate?
    
    init(url: String){
        self.url = URL(string: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension SingPassVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard let loadedURL = webView.url else {return}
        
        if loadedURL.absoluteString.contains("https://assets.pacenow.co/r.html?_stat=SUCCESS") {
            print("Redirect URL: \(loadedURL.absoluteString)")
            navigationController?.popViewController(animated: true)
            delegate?.loadMyInforequestResutApi()
        }
  // https://assets.pacenow.co/r.html?_stat=SUCCESS&_ref=f8e2631af55542e35a559f3faf82d1030beb4adb&code=b91606bfc44e2a61a7896246e4047729ed19132c&state=f8e2631af55542e35a559f3faf82d1030beb4adb
    }
}
