//
//  UINavigationController+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

extension UINavigationController {
    func popViewController(animated: Bool,
                           completion: @escaping () -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        self.popViewController(animated: animated)
        
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool,
                                 completion: @escaping () -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        self.popToRootViewController(animated: animated)
        
        
        CATransaction.commit()
    }
}
