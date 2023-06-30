//
//  IdLoginVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/30.
//

import UIKit
import TextFieldEffects
import RxSwift
import RxCocoa
import RxRelay

class IdLoginVC: BaseVC {
    @IBOutlet weak var scrV: UIScrollView!
    @IBOutlet var contentV: UIView!
    
    @IBOutlet weak var idTF: HoshiTextField!
    @IBOutlet weak var pwdTF: HoshiTextField!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var completeBTN: BlackBTN!
    
    private var check1 = BehaviorRelay<Bool>(value: false)
    private var check2 = BehaviorRelay<Bool>(value: false)
    
    private var vm: IdLoginVM!
    convenience init(vm: IdLoginVM?) {
        self.init(nibName: "IdLogin", bundle: nil)
        guard let vm = vm else { return }
        self.vm = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.organizeSubviews()
        self.settingsSubviews()
        self.bindUserEvents()
        self.bindUI()
        self.bindOutputs()
    }
    
    private func organizeSubviews(){
        self.scrV.addSubview(self.contentV)
        self.contentV.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.width.equalTo(SCREEN_WIDTH)
        }
    }
    
    private func settingsSubviews() {
        self.naviBarHidden = false
        self.navigationItem.title = "로그인"
        
        self.view.backgroundColor = DARK_COLOR
        
        self.scrV.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.keyboardDismissMode = .onDrag
        }
        
        self.idTF.do {
            $0.placeholder = "아이디"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .asciiCapable
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.settingCloseToolBar()
        }
        
        self.pwdTF.do {
            $0.placeholder = "비밀번호"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .default
            $0.isSecureTextEntry = true
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.settingCloseToolBar()
        }
    }
    
    private func bindUserEvents() {
        self.idTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self = self else {return}
                
                guard var text = text else {
                    return
                }
                if text.count > 20 {
                    text.removeLast()
                    self.idTF.text = text
                } else {
                    if text.count > 3 {
                        self.check1.accept(true)
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.pwdTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self = self else {return}
                guard var text = text else {
                    return
                }
                
                if text.count > 20  {
                    text.removeLast()
                    self.pwdTF.text = text
                } else {
                    if text.count > 3 {
                        self.check2.accept(true)
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.completeBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                guard let id = self.idTF.text,
                      let pwd = self.pwdTF.text else { return }
                CommonLoading.shared.show()
                UserManager.shared.idLogin(id: id, password: pwd) {
                    CommonLoading.shared.hide()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func removeSpecial(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        
        return String(text.filter {okayChars.contains($0) })
    }
     
    private func bindUI() {
        var newHeight: CGFloat = 0
        if let uTab = self.tabBarController?.tabBar,
           uTab.isHidden == false {
            newHeight += uTab.frame.height
        } else if let safeBot = UIApplication.getKeyWindow()?.safeAreaInsets.bottom{
            newHeight += safeBot
        }
        
        self.setKeyboardNotiHandler(constraint: self.keyboardConstraint, constantValue: newHeight, disposeBag: self.disposeBag, superView: self.view)
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.pwdTF, dpBag: self.disposeBag, flexibleValue: -100)
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.idTF, dpBag: self.disposeBag, flexibleValue: -100)
    }
    
    private func bindOutputs() {
        Observable
            .combineLatest(self.check1, self.check2)
            .map { arg -> Bool in
                return arg.0 && arg.1
            }
            .bind(to: self.completeBTN.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }

}
