//
//  UITextField+Ext.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit

extension UITextField {
    func settingCloseToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let closeBtn = UIBarButtonItem(title: "닫기", style: .done, target: self, action: #selector(self.closeKeyboard))
        toolBar.items = [closeBtn]
        self.inputAccessoryView = toolBar
    }
    
    @objc private func closeKeyboard() {
        self.resignFirstResponder()
    }
}

extension UITextView {
    func settingCloseToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let closeBtn = UIBarButtonItem(title: "닫기", style: .done, target: self, action: #selector(self.closeKeyboard))
        toolBar.items = [closeBtn]
        self.inputAccessoryView = toolBar
    }
    
    @objc private func closeKeyboard() {
        self.resignFirstResponder()
    }
}
