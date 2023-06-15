//
//  TabBar.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit
import Hex

class TabBar:UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.settingSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.settingSubViews()
    }
    
    private var shareLayer:CALayer?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private func settingSubViews() {
        self.barTintColor = .init(hex: "ffffff")
        self.backgroundImage = UIImage()
        
        self.setupStyle()
    }
    
    private func setupStyle() {
        self.clearShadow()
        self.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        
        let height: CGFloat = 48
        let safetyBot = SAFEAREA_INSET.bottom
        newSize.height = height + safetyBot
        
        return newSize
    }

}

extension TabBar {
    // 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용할 수 있다.
    func clearShadow() {
        TabBar.appearance().shadowImage = UIImage()
        TabBar.appearance().backgroundImage = UIImage()
        TabBar.appearance().backgroundColor = UIColor.white
    }
}
