//
//  CustomTF.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import TextFieldEffects

class CustomTF: HoshiTextField {
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.frame.width - 20, y: 25, width: 22, height: 22)
    }
}
