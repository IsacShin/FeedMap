//
//  TabBarVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit

final class TabBarVC: UITabBarController {
    
    private let container = DIM.container
    private let navi1 = BaseNaviVC()
    private let navi2 = BaseNaviVC()
    private let navi3 = BaseNaviVC()
    private let navi4 = BaseNaviVC()
    private let navi5 = BaseNaviVC()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingSubviews()
        self.settingController()
    }
    
    private func settingSubviews() {
        self.setValue(TabBar(), forKey: "tabBar")
    }
    
    private func settingController() {
        
        
        self.hidesBottomBarWhenPushed = true
        self.delegate = self
    }
}

extension TabBarVC:UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
