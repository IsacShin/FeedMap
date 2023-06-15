//
//  CommonLoadingVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit
import iProgressHUD

class CommonLoading {
    static let shared = CommonLoading()
    let iprogress: iProgressHUD = iProgressHUD()

    private init() {
       settingProgress()
    }
    
    private func settingProgress() {
        iprogress.indicatorStyle = .ballTrianglePath
        iprogress.indicatorSize = 30
        iprogress.boxSize = 30
        iprogress.boxCorner = 12
        iprogress.isShowBox = true
        iprogress.isBlurBox = false

    }
    
    func show(_ view:UIView = (WINDOW?.rootViewController?.view)!) {
        iprogress.attachProgress(toView: view)
        view.showProgress()
    }
    
    func hide(_ view:UIView = (WINDOW?.rootViewController?.view)!) {
        view.dismissProgress()
    }
}
