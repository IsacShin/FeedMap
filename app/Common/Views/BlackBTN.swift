//
//  BlackBTN.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit

class BlackBTN: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit(){
        
        self.do{
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
            $0.titleLabel?.font = .medium(size: 16)
            $0.setTitleColor(.init(hex: "ffffff"), for: .normal)
            $0.setTitleColor(.init(hex: "B8BDBB"), for: .disabled)
            $0.setBackgroundImage(.init(color: .init(hex: "000000")), for: .normal)
            $0.setBackgroundImage(.init(color: .init(hex: "EFF1EA")), for: .disabled)
        }
    }
}
