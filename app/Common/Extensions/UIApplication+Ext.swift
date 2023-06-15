//
//  UIApplication+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController(_ base: UIViewController? = WINDOW?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }

        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }

        return base
    }
    
    class func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .first?.windows
            .filter {
                $0.isKeyWindow
            }
            .first
    }
}
