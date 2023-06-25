//
//  BaseNaviVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit

class BaseNaviVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.settingSubviews()
    }
        
    private func settingSubviews(){
        
        self.navigationBar.do{
        
            let img = UIImage(named: "icoBack")?.withRenderingMode(.alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0))
            
            $0.backIndicatorImage = img
            $0.backIndicatorTransitionMaskImage = img
            
            $0.setBackgroundImage(UIImage(), for: .default)
            $0.barTintColor = DARK_COLOR
            $0.isTranslucent = false
            
            var textAttr = [NSAttributedString.Key: Any]()
            textAttr[.font] = UIFont.regular(size: 18)
            textAttr[.foregroundColor] = UIColor.init(hex: "ffffff")
            $0.titleTextAttributes = textAttr
        }
        
        
        UIBarButtonItem
            .appearance()
            .setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -3), for: .default)
        
        
        if #available(iOS 15, *){
            
            let appp = UINavigationBarAppearance()
            
            appp.configureWithOpaqueBackground()
            
            let img = UIImage(named: "icoBack")?.withRenderingMode(.alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0))
            appp.setBackIndicatorImage(img, transitionMaskImage: img)
            appp.backgroundColor = DARK_COLOR
            
            
            var textAttr = [NSAttributedString.Key: Any]()
            textAttr[.font] = UIFont.regular(size: 20)
            textAttr[.foregroundColor] = UIColor.init(hex: "ffffff")
            appp.titleTextAttributes = textAttr
            
            UINavigationBar.appearance().standardAppearance = appp
            UINavigationBar.appearance().scrollEdgeAppearance = appp
        }
        
        self.interactivePopGestureRecognizer?.delegate = self
        // naviBack gesture
//        let recognizer = WDDNaviBackRecognizer(controller: self)
//        self.interactivePopGestureRecognizer?.delegate = recognizer
    }

}

extension BaseNaviVC: UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        
    }
}

extension BaseNaviVC: UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.viewControllers.count > 1
    }
}
