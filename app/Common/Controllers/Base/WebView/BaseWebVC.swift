//
//  BaseWebVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import SnapKit

class BaseWebVC: BaseVC {
    //IBOutlet
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    var webView:WKWebView!
    var configuration:WKWebViewConfiguration?
    var urlString:String?
    private var vm:BaseWebVM!
    convenience init(vm: BaseWebVM?) {
        self.init(nibName: "Base", bundle: nil)
        guard let wVM = vm else { return }
        self.vm = wVM
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideFooter()
        self.naviBarHidden = false
        self.createWebView()
        self.bindUserEvents()
        
        self.vm.urlStr
            .debug()
            .subscribe { [weak self] urlString in
                guard let self = self else { return }
                guard let element = urlString.element,
                      let urlStr = element else { return }
                self.requestWebView(urlStr)
            }
            .disposed(by: self.disposeBag)
        
    }
    
    private func bindUserEvents() {
        self.backBtn.rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive { [weak self]_ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: self.disposeBag)
        
//        self.webView.scrollView
//            .rx
//            .willEndDragging
//            .subscribe { velocity, offSet in
//                if(velocity.y > 0) {
//                    self.hideFooter()
//                }else{
//                    self.showFooter()
//                }
//            }.disposed(by: self.disposeBag)
        
        self.leftBtn.rx
            .tap
            .asDriver()
            .drive { [weak self]_ in
                guard let self = self else { return }
                if self.webView.canGoBack {
                    self.webView.goBack()
                }
            }.disposed(by: self.disposeBag)
        
        self.rightBtn.rx
            .tap
            .asDriver()
            .drive { [weak self]_ in
                guard let self = self else { return }
                if self.webView.canGoForward {
                    self.webView.goForward()
                }
            }.disposed(by: self.disposeBag)
        
    }
    
    func requestWebView(_ urlStr:String) {
        if let value = URL(string: urlStr) {
            var request = URLRequest(url: value)
            
            self.webView.load(request)
        }
    }
    
    func createWebView() {
        if let config = configuration {
            self.webView = WKWebView(frame: self.view.frame, configuration: config)
        }else {
            let config = WKWebViewConfiguration()
            
            if #available(iOS 14.0, *){
                config.defaultWebpagePreferences.allowsContentJavaScript = true
            } else {
                config.preferences.javaScriptEnabled = true
            }
            
            let controller = WKUserContentController()
            controller.add(self, name: "W2A")
            config.userContentController = controller
            config.applicationNameForUserAgent = "" //userAgent
            config.processPool = SharedPool.shared.commonProcessPool
            
            self.webView = WKWebView(frame: self.view.frame, configuration: config)
        }
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.webView.backgroundColor = .white
        self.webView.scrollView.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        self.containerView.addSubview(self.webView)
        
        self.webView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.containerView)
        }
        
        DispatchQueue.main.async {
            if let urlStr = self.urlString {
                self.vm.urlStr.accept(urlStr)
            }
        }
        
    }
    
    func hideFooter() {
        bottomConst.constant = -self.footerView.frame.height
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }

    }
    
    func showFooter() {
        bottomConst.constant = 0
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension BaseWebVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            return
        }
        
        guard let jibunAddress = body["jibunAddress"] as? String,
              let roadAddress = body["roadAddress"] as? String,
              let zonecode = body["zonecode"] as? String else { return }
        
        print("\(jibunAddress)\n\(roadAddress)\n\(zonecode)")

        self.navigationController?.popViewController(animated: true, completion: {
            var userInfo = [String: Any]()
            
            userInfo["jibunAddress"] = jibunAddress
            userInfo["roadAddress"] = roadAddress
            userInfo["zonecode"] = zonecode
            
            NotificationCenter
                .default
                .post(name: Notification.Name("addrInfo"),
                      object: nil,
                      userInfo: userInfo)
        })
    }
}

extension BaseWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LOADING.show()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let baseUrl = webView.url?.absoluteString ?? ""
        let requestUrl = navigationAction.request.url?.absoluteString ?? ""
        
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LOADING.hide()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        LOADING.hide()
    }
    
}

extension BaseWebVC: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        CommonAlert.showAlertType(vc: self, title: "", message: message, completeTitle: "확인", completionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let completionHandlerWrapper = CompletionHandlerWrapper(completionHandler: completionHandler, defaultValue: false)
        
        CommonAlert.showConfirmType(vc: self, title: "", message: message, cancelTitle: "취소", completeTitle: "확인") {
            completionHandlerWrapper.respondHandler(false)
        } _: {
            completionHandlerWrapper.respondHandler(true)
        }
    }
    
    // 새창 열기
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let targetFrame = navigationAction.targetFrame
        
        if targetFrame == nil {
            let urlStr = navigationAction.request.url?.absoluteString ?? ""
            if urlStr != "" {
                self.openUrl(urlStr)
            }
        }
        return nil
    }
    
    // 사설SSL 인증
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
      
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }else{
            completionHandler(.useCredential, nil)
        }
    }

}
