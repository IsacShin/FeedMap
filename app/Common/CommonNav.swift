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
        let naviVC = BaseNaviVC(rootViewController: vc)
        naviVC.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()?.present(naviVC, animated: true)
    }
    
    static func moveIdLoginVC() {
        guard let vc = DIM.container.resolve(IdLoginVC.self) else { return }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func moveFeedWriteVC(seed: FeedWriteSeedInfo) {
        guard let vc = DIM.container.resolve(FeedWriteVC.self, argument: seed) else { return }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func moveTermsVC() {
        guard let vc = DIM.container.resolve(TermsVC.self) else { return }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func moveJoinVC() {
        guard let vc = DIM.container.resolve(JoinVC.self) else { return }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
