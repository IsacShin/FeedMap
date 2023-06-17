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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingSubviews()
        self.settingController()
    }
    
    private func settingSubviews() {
        self.setValue(TabBar(), forKey: "tabBar")
    }
    
    private func settingController() {
        self.tabBar.unselectedItemTintColor = .white
        UITabBar.appearance().tintColor = .lightGray

        guard let mapVC = container.resolve(MapVC.self),
              let feedVC = container.resolve(FeedVC.self),
              let myPageVC = container.resolve(MyPageVC.self)
        else {
            return
        }
        
        self.navi1.setViewControllers([mapVC], animated: false)

        let map = UITabBarItem()
        map.do{
            let img = UIImage(systemName: "map")?.withTintColor(.white)
            let disImg = UIImage(systemName: "map")?.withTintColor(.white)
            $0.image = disImg
            $0.selectedImage = img
            $0.title = nil
            $0.imageInsets = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)

            self.navi1.tabBarItem = $0
        }
        self.addChild(self.navi1)
        
        self.navi2.setViewControllers([feedVC], animated: false)

        let feed = UITabBarItem()
        feed.do{
            let img = UIImage(systemName: "list.bullet.below.rectangle")
            let disImg = UIImage(systemName: "list.bullet.below.rectangle")
            $0.image = disImg
            $0.selectedImage = img
            $0.title = nil
            $0.imageInsets = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)

            self.navi2.tabBarItem = $0
        }
        self.addChild(self.navi2)
        
        self.navi3.setViewControllers([myPageVC], animated: false)

        let myPage = UITabBarItem()
        myPage.do{
            let img = UIImage(systemName: "person")
            let disImg = UIImage(systemName: "person")
            $0.image = disImg
            $0.selectedImage = img
            $0.title = nil
            $0.imageInsets = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)

            self.navi3.tabBarItem = $0
        }
        self.addChild(self.navi3)
        
        self.children.compactMap {
            $0.tabBarItem
        }.forEach {
            $0.title = nil
            var offset:CGFloat = 5
            if traitCollection.horizontalSizeClass == .regular {
                offset = 0
            }
            $0.imageInsets = UIEdgeInsets(top: offset, left: 0, bottom: -offset, right: 0)
        }
        
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
