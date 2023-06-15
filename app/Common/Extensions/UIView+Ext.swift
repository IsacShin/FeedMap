//
//  UIView+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

extension UIView {
    func makeShadow() {
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowOpacity = 0.7
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 8
        self.layer.masksToBounds = false
    }
    
    func toggleVTheme() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.backgroundColor = .systemGray4

        }else {
            self.backgroundColor = .white

        }
    }
    
    func roundCorners(cornerRadius: CGFloat, byRoundingCorners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: byRoundingCorners,
                                cornerRadii: CGSize(width:cornerRadius, height: cornerRadius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        
        layer.mask = maskLayer
    }
}
