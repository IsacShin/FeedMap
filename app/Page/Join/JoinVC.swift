//
//  JoinVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/29.
//

import UIKit
import TextFieldEffects

class JoinVC: BaseVC {
    
    @IBOutlet weak var scrV: UIScrollView!
    @IBOutlet var contentV: UIView!
    
    @IBOutlet weak var nameTF: HoshiTextField!
    @IBOutlet weak var idTF: HoshiTextField!
    
    @IBOutlet weak var pwdTF: HoshiTextField!
    @IBOutlet weak var pwdCheckTF: HoshiTextField!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileV: UIView!
    @IBOutlet weak var profileIMG: UIImageView!
    @IBOutlet weak var profileBTN: UIButton!
    
    @IBOutlet weak var plusIMG: UIImageView!
    private var vm: JoinVM!
    convenience init(vm: JoinVM?) {
        self.init(nibName: "Join", bundle: nil)
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
            $0.height.equalTo(SCREEN_HEIGHT)
        }
    }
    
    private func settingsSubviews() {
        self.naviBarHidden = false
        self.navigationController?.title = "회원가입"
        
        self.view.backgroundColor = DARK_COLOR
        
        self.scrV.do {
            $0.backgroundColor = .clear
            $0.keyboardDismissMode = .onDrag
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        self.profileV.do {
            $0.layer.cornerRadius = $0.frame.width / 2
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 2
            $0.backgroundColor = DARK_COLOR
            $0.clipsToBounds = true
        }
        
        self.plusIMG.do {
            let img = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
            $0.image = img
            $0.tintColor = .white
        }
        
        self.nameTF.do {
            $0.placeholder = "이름"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .default
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.delegate = self
        }
        
        self.idTF.do {
            $0.placeholder = "아이디"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .default
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.delegate = self
        }
        
        self.pwdTF.do {
            $0.placeholder = "비밀번호"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .default
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.delegate = self
        }
        
        self.pwdCheckTF.do {
            $0.placeholder = "비밀번호 확인"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .default
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.delegate = self
        }
    }
    
    private func bindUserEvents() {
        self.nameTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else {return}
                
                if var text = self.nameTF.text, text.count > 10  {
                    text.removeLast()
                    self.nameTF.text = text
                }
            })
            .disposed(by: self.disposeBag)
        
        self.idTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else {return}
                
                if var text = self.idTF.text, text.count > 20  {
                    text.removeLast()
                    self.idTF.text = text
                }
            })
            .disposed(by: self.disposeBag)
        
        self.pwdTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else {return}
                
                if var text = self.pwdTF.text, text.count > 20  {
                    text.removeLast()
                    self.pwdTF.text = text
                }
            })
            .disposed(by: self.disposeBag)
        
        self.pwdCheckTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self = self else {return}
                guard let pwdTxt = pwdTF.text,
                      let text = text else { return }
                if text != pwdTxt {
                    self.pwdCheckTF.placeholder = "비밀번호를 확인해주세요."
                    self.pwdCheckTF.placeholderColor = .red
                } else {
                    self.pwdCheckTF.placeholder = "비밀번호를 확인"
                    self.pwdCheckTF.placeholderColor = .white
                    self.pwdCheckTF.text = text
                }
            })
            .disposed(by: self.disposeBag)
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
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.nameTF, dpBag: self.disposeBag, flexibleValue: -100)
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.idTF, dpBag: self.disposeBag, flexibleValue: -100)
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.pwdTF, dpBag: self.disposeBag, flexibleValue: -100)
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.pwdCheckTF, dpBag: self.disposeBag, flexibleValue: -100)
    }
    
    private func bindOutputs() {
        
    }
    
}


extension JoinVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.idTF {
            let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9]+$", options: .anchorsMatchLines)
            return regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).count > 0
        }
        
        return true
    }
}
