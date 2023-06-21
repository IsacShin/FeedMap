//
//  CommonNav.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit

final class CommonNav {
    
    static func moveToHome() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        AppD.navigationVC?.view.layer.add(transition, forKey: nil)
        
        AppD.navigationVC?.setViewControllers([TabBarVC()], animated: false)
    }
    
    static func moveBaseWebVC(requestUrl: String) {
        guard let vc = DIM.container.resolve(BaseWebVC.self) else { return }
        vc.urlString = requestUrl
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func moveAccessGuideVC() {
        guard let vc = DIM.container.resolve(AccessGuideVC.self) else { return }
        vc.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()?.present(vc, animated: true)
    }
    
    static func moveLoginVC() {
        guard let vc = DIM.container.resolve(LoginVC.self) else { return }
        vc.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()?.present(vc, animated: true)
    }
    
    static func moveFeedWriteVC() {
        guard let vc = DIM.container.resolve(FeedWriteVC.self) else { return }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
