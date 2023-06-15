//
//  UILabel+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

extension UILabel {
    public func toggleTheme() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.textColor = LIGHT_COLOR
        }else {
            self.textColor = .black
        }
    }
    public func setLabel(font: UIFont, color: String, textAlignment: NSTextAlignment) {
        self.font = font
        self.textColor = UIColor.init(hex: color)
        self.textAlignment = textAlignment
    }
    
    public func setCharacterSpacing(kernValue: Double = -0.9) {
        guard let text = self.text,
              text.isEmpty == false else {
            return
        }
        
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        self.attributedText = string
    }
    
    public func setLineHeight(spacing: CGFloat) {
        if let text = self.text {
            let uText = text
            
            let attrString = NSMutableAttributedString(string: uText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = spacing
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    }
    
    public func setRangeLabel(rtext: [String], font: UIFont, color: UIColor, spacing: CGFloat, textAlignment: NSTextAlignment = .left) {
        guard let fullTxt = self.text,
              fullTxt.isEmpty == false else {
            return
        }
        
        let attributedString = NSMutableAttributedString(string: fullTxt)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = textAlignment
        for txt in rtext {
            let range = (fullTxt as NSString).range(of: txt)
            attributedString.addAttributes([.font: font as Any, .foregroundColor: color as Any], range: range)
        }
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
    func calculateLineCount() -> Int{
        var max = CGSize.init(width: self.frame.width, height: CGFloat(Float.infinity))
        
        // Cell에서 label의 size가 0으로 잡히는 경우가 있음
        if max.width == 0 {
            max = UIScreen.main.bounds.size
        }
        
        let charSize = self.font.lineHeight
        let text = self.text ?? ""
        let uText = NSString(string: text)
        var attr = [NSAttributedString.Key : Any]()
        attr[.font] = self.font
        let textSize = uText.boundingRect(with: max,
                                          options: .usesLineFragmentOrigin,
                                          attributes: attr,
                                          context: nil)
        
        let lineCount = Int(ceil(textSize.height / charSize))
        return lineCount
    }
}
