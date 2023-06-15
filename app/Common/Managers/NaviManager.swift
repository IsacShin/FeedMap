//
//  NaviManager.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

final class NaviManager {
    static let shared = NaviManager()
    
    public func resetNavi(completion: (() -> Void)? = nil) {
        let tabBarC = TabBarVC()
        
        UIApplication.getKeyWindow()?.rootViewController = tabBarC
        NaviManager.shared.resetNaviStack {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                completion?()
            })
        }
    }
    
    public func resetNaviStack(completion: (() -> Void)?) {
        guard let top = UIApplication.topViewController() else {
            return
        }
        
        guard (top is MapVC) == false else {
            completion?()
            return
        }
        
        if top.isModal {
            top.dismiss(animated: false) {
                NaviManager.shared.resetNavi(completion: completion)
            }
        } else {
            guard let navi = top.navigationController,
                  navi.viewControllers.count > 1 else {
                top.tabBarController?.selectedIndex = 0
                completion?()
                return
            }
            
            top.navigationController?.popViewController(animated: false, completion: {
                NaviManager.shared.resetNaviStack(completion: completion)
            })
        }
    }
}
