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
    func settingScrVAutoScrollToTargetV(scrV: UIScrollView, targetV: UIView, dpBag: DisposeBag, flexibleValue: CGFloat, hasMax: Bool)
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
    
    func settingScrVAutoScrollToTargetV(scrV: UIScrollView, targetV: UIView, dpBag: DisposeBag, flexibleValue: CGFloat, hasMax: Bool = true){
        let notiCenter = NotificationCenter.default.rx
     
        let scrollToVisible = { (scrV: UIScrollView, targetV: UIView) in
            
            guard targetV is UITextField || targetV is UITextView else {
                return
            }
            guard targetV.isFirstResponder == true else {
                return
            }
            let targetVLocation = targetV.convert(targetV.frame.origin, to: scrV)
            let max = scrV.contentSize.height - scrV.frame.height + scrV.contentInset.top + scrV.contentInset.bottom
            var newY = targetVLocation.y + flexibleValue
            
            if hasMax == true {
                if newY > max {
                    newY = max
                }
            }
            
            scrV.setContentOffset(.init(x: 0, y: newY), animated: false)
            
        }
        notiCenter
            .notification(UIResponder.keyboardWillShowNotification)
            .asDriver(onErrorJustReturn: Notification(name: UIResponder.keyboardWillShowNotification))
            .drive(onNext: { (noti) in
        
                guard let uUserinfo = noti.userInfo,
                    let duration = uUserinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                    let aniType = uUserinfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else{
                        
                        return
                        
                }
                
                UIView
                    .animate(withDuration: duration,
                               delay: 0,
                               options: UIView.AnimationOptions(rawValue: aniType),
                               animations: {
                                
                        // 해당 텍스트뷰가 현재화면에 나올 수 있도록 스크롤뷰 오프셋을 이동한다.
                        scrollToVisible(scrV, targetV)
                        
                                
                    },
                               completion: nil)
                
            })
        .disposed(by: dpBag)
        
    }
}
