//
//  BaseVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxAlamofire
import GoogleMobileAds
import RxRelay

class BaseVC: UIViewController, UIGestureRecognizerDelegate {

    var naviBarHidden = true
    var naviAnitype = true
    var naviLineHidden = true

    let disposeBag = DisposeBag()

    var footerInset: CGFloat {
        let FooterHeight: CGFloat = 58
        
        if #available(iOS 11.0, *) {
            let bottomPadding = (WINDOW?.safeAreaInsets.bottom) ?? 0
            return bottomPadding + FooterHeight
        } else {
            return bottomLayoutGuide.length + FooterHeight
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingEndKeyboard()
        self.view.backgroundColor = .white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(self.naviBarHidden, animated: naviAnitype)
        self.navigationController?.navigationBar.setValue(self.naviLineHidden, forKey: "hidesShadow")

        if #available(iOS 15, *){
        
            let appp = UINavigationBar.appearance().standardAppearance
            
            if self.naviLineHidden == true {
                appp.shadowColor = .clear
            } else{
                appp.shadowColor = .black
            }
            self.navigationController?.navigationBar.scrollEdgeAppearance = appp
            self.navigationController?.navigationBar.standardAppearance = appp
        }
        
        
        super.viewWillAppear(animated)
    }
    
    /// Open Url
    func openUrl(_ urlString: String, _ handler:(() -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            return //be safe
        }
        
        UIApplication.shared.open(url, options: [:]) { result in
            handler?()
        }
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }


}

extension BaseVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
}

extension BaseVC: CommonKeyboardHandler {}

// 키보드 숨김 관련
extension BaseVC {
    func settingEndKeyboard(isCancelTouchV: Bool = false) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.endKeyboard))
        
        gesture.cancelsTouchesInView = isCancelTouchV
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func endKeyboard() {
        self.view.endEditing(true)
    }
    
}

extension BaseVC: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}
