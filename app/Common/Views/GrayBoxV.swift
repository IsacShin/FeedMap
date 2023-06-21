//
//  GrayBoxV.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import UIKit

class GrayBoxV: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit(){
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.backgroundColor = .init(hex: "f7f7f7")
        
    }

}
