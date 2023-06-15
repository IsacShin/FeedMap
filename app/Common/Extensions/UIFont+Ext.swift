//
//  UIFont+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

extension UIFont{
    
    public class func black(size: CGFloat) -> UIFont{
                
        guard let blackFont = UIFont(name: "NotoSansCJKkr-Black", size: size) else {
            return .systemFont(ofSize: size, weight: .black)
        }
        
        return blackFont
    }
    
    public class func bold(size: CGFloat) -> UIFont{
        guard let boldFont = UIFont(name: "NotoSansCJKkr-Bold", size: size) else {
            return .systemFont(ofSize: size, weight: .bold)
        }
        
        return boldFont
    }
    
    public class func medium(size: CGFloat) -> UIFont{
        
        guard let mediumFont = UIFont(name: "NotoSansCJKkr-Medium", size: size) else {
            return .systemFont(ofSize: size, weight: .medium)
        }
        
        return mediumFont
    }
    
    public class func regular(size: CGFloat) -> UIFont{
        
        guard let regularFont = UIFont(name: "NotoSansCJKkr-Regular", size: size) else {
            return .systemFont(ofSize: size, weight: .regular)
        }
        
        return regularFont
    }
    
    
    public class func light(size: CGFloat) -> UIFont{
        
        guard let lightFont = UIFont(name: "NotoSansCJKkr-Light", size: size) else {
            return .systemFont(ofSize: size, weight: .light)
        }
        
        return lightFont
    }
    
    public class func demiLight(size: CGFloat) -> UIFont{
        
        guard let demiLightFont = UIFont(name: "NotoSansCJKkr-DemiLight", size: size) else {
            return .systemFont(ofSize: size, weight: .ultraLight)
        }
        
        return demiLightFont
    }
    
    public class func thin(size: CGFloat) -> UIFont{
        
        guard let thinFont = UIFont(name: "NotoSansCJKkr-Thin", size: size) else {
            return .systemFont(ofSize: size, weight: .thin)
        }
        
        return thinFont
    }
    
}
