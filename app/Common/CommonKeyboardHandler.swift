//
//  CommonKeyboardHandler.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import RxCocoa
import RxSwift

protocol CommonKeyboardHandler:UIViewController {
    func setKeyboardNotiHandler(constraint:NSLayoutConstraint, constantValue:CGFloat, disposeBag:DisposeBag, superView:UIView)
}

extension CommonKeyboardHandler {
    func setKeyboardNotiHandler(constraint:NSLayoutConstraint, constantValue:CGFloat, disposeBag:DisposeBag, superView:UIView) {
        let notiCenter = NotificationCenter.default.rx
        
        notiCenter
            .notification(UIResponder.keyboardWillShowNotification)
            .asDriver(onErrorJustReturn: Notification(name: UIResponder.keyboardWillShowNotification))
            .drive(onNext: { noti in
                guard let userInfo = noti.userInfo,
                      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return}
                
                let newHeight:CGFloat = keyboardFrame.height - constantValue
                
                UIView.animateKeyframes(withDuration: duration, delay: 0, animations: {
                    constraint.constant = newHeight
                    superView.layoutIfNeeded()
                }, completion: nil)
            })
            .disposed(by: disposeBag)
        
        notiCenter
            .notification(UIResponder.keyboardWillHideNotification)
            .asDriver(onErrorJustReturn: Notification(name: UIResponder.keyboardWillHideNotification))
            .drive(onNext: { noti in
                guard let userInfo = noti.userInfo,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return}
                                
                UIView.animateKeyframes(withDuration: duration, delay: 0, animations: {
                    constraint.constant = 0
                    superView.layoutIfNeeded()
                }, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
