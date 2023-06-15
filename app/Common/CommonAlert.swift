//
//  CommonAlert.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit

// MARK: - 공통 얼럿
class CommonAlert {
    static func showAlertType(vc:UIViewController,
                              title:String = "",
                              message:String = "",
                              completeTitle:String = "확인",
                              _ completeHandler:(() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: completeTitle, style: .default) { action in
            completeHandler?()
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showConfirmType(vc:UIViewController,
                                title:String = "",
                                message:String = "",
                                cancelTitle:String = "취소",
                                completeTitle:String = "확인",
                                _ cancelHandler:(() -> Void)? = nil,
                                _ completeHandler:(() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
            cancelHandler?()
        }
        let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
            completeHandler?()
        }
        alert.addAction(cancelAction)
        alert.addAction(completeAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
}

