//
//  JoinVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/29.
//

import UIKit
import TextFieldEffects
import RxSwift
import RxCocoa
import RxRelay

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
    
    @IBOutlet weak var completeBTN: BlackBTN!
    
    @IBOutlet var term1CheckBTN: UIButton!
    @IBOutlet var term1MoreBTN: UIButton!
    @IBOutlet var term1CheckTRBTN: UIButton!
    
    @IBOutlet weak var term1CheckLB: UILabel!
    
    
    private var check1 = BehaviorRelay<Bool>(value: false)
    private var check2 = BehaviorRelay<Bool>(value: false)
    private var check3 = BehaviorRelay<Bool>(value: false)
    private var check4 = BehaviorRelay<Bool>(value: false)
    
    private var term1Check = BehaviorRelay<Bool>(value: false)
    
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
        }
    }
    
    private func settingsSubviews() {
        self.naviBarHidden = false
        self.navigationItem.title = "회원가입"
        
        self.view.backgroundColor = DARK_COLOR
        
        self.scrV.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.keyboardDismissMode = .onDrag
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
            $0.settingCloseToolBar()
        }
        
        self.idTF.do {
            $0.placeholder = "아이디"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .asciiCapable
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.delegate = self
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
            $0.delegate = self
            $0.settingCloseToolBar()
        }
        
        self.pwdCheckTF.do {
            $0.placeholder = "비밀번호 확인"
            $0.placeholderColor = .white
            $0.placeholderFontScale = 1.1
            $0.keyboardType = .default
            $0.isSecureTextEntry = true
            $0.backgroundColor = .clear
            $0.textColor = .lightGray
            $0.font = .regular(size: 16)
            $0.delegate = self
            $0.settingCloseToolBar()
        }
        
        self.profileIMG.do {
            $0.contentMode = .scaleAspectFill
        }
        
        self.term1CheckBTN.do {
            $0.setImage(.init(named: "chkOn"), for: .selected)
            $0.setImage(.init(named: "chkOff"), for: .normal)
            $0.isUserInteractionEnabled = false
        }
        
        self.term1CheckLB.do {
            $0.font = .regular(size: 14)
            $0.textColor = .white
        }
    }
    
    private func bindUserEvents() {
        self.nameTF
            .rx
            .text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self = self else {return}
                guard var text = text else {
                    return
                }
                if text.count > 10 {
                    text.removeLast()
                    self.nameTF.text = text
                } else {
                    if text.count > 1 {
                        self.check1.accept(true)
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
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
                        self.check2.accept(true)
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
                    if text.count < 1 {
                        self.pwdCheckTF.isUserInteractionEnabled = false
                    } else {
                        if text.count > 3 {
                            self.check3.accept(true)
                        }
                        self.pwdCheckTF.isUserInteractionEnabled = true
                    }
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
                    self.check4.accept(false)
                    self.pwdCheckTF.placeholder = "비밀번호를 확인해주세요."
                    self.pwdCheckTF.placeholderColor = .red
                } else {
                    self.pwdCheckTF.placeholder = "비밀번호를 확인"
                    self.pwdCheckTF.placeholderColor = .white
                    self.pwdCheckTF.text = text
                    if pwdTxt != "" && text == pwdTxt {
                        self.check4.accept(true)
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.profileBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                CommonPickerManager.shared.showYpAlbum(maxCount: 1) { [weak self] sModelList in
                    guard let self = self else {
                        return
                    }
                    
                    let cList = sModelList.compactMap { origin -> ImgSelectColVCellDPModel? in
                        guard let name = origin.fileName else {
                            return nil
                        }
                        
                        return .init(img: origin.img, fileName: name)
                    }
                    self.vm.input.addImage(imgList: cList)
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
                      let name = self.nameTF.text,
                      let pwd = self.pwdTF.text else { return }
                let param: [String: Any] = [
                    "memid" : id as Any,
                    "name" : name.replacingOccurrences(of: "[^a-zA-Z0-9가-힣\\s]", with: "", options: .regularExpression) as Any,
                    "password" : pwd as Any
                ]
                CommonLoading.shared.show()
                self.vm.input.regist(info: param, completion: {
                    CommonLoading.shared.hide()
                })
            })
            .disposed(by: self.disposeBag)
        
        self.term1CheckTRBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .compactMap { [weak self]_ -> Bool? in
                
                guard let self = self else {
                    return nil
                }
                return !self.term1Check.value
            }
            .drive(self.term1Check)
            .disposed(by: self.disposeBag)
        
        self.term1MoreBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                let url = DOMAIN + "/serviceTerms.do"
                CommonNav.moveBaseWebVC(requestUrl: url)
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
        let output = self.vm.output
        
        self.term1Check
            .asDriver()
            .drive(self.term1CheckBTN.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        output
            .imgDataList
            .asDriver()
            .compactMap {
                $0?.first
            }
            .drive(onNext: { [weak self] model in
                guard let self = self else { return }
                if let img = model.img {
                    self.profileIMG.image = img
                } else {
                    self.profileIMG.image = nil
                }
            })
            .disposed(by: self.disposeBag)
        
        output
            .success
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] result in
                guard let self = self else { return }
                if result == true {
                    CommonAlert.showAlertType(vc: self, message: "가입되었습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    CommonAlert.showAlertType(vc: self, message: "문제가 발생하였습니다.\n다시 시도해주세요.", nil)
                }
            })
            .disposed(by: self.disposeBag)
        
        Observable
            .combineLatest(self.check1, self.check2, self.check3, self.check4, self.term1Check)
            .map { arg -> Bool in
                return arg.0 && arg.1 && arg.2 && arg.3 && arg.4
            }
            .bind(to: self.completeBTN.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    private func nameValidation(text: String) -> Bool {
        // String -> Array
        let arr = Array(text)
        // 정규식 pattern. 한글, 영어, 숫자, 밑줄(_)만 있어야함
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣ]$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            var index = 0
            while index < arr.count { // string 내 각 문자 하나하나 마다 정규식 체크 후 충족하지 못한것은 제거.
                let results = regex.matches(in: String(arr[index]), options: [], range: NSRange(location: 0, length: 1))
                if results.count == 0 {
                    return false
                } else {
                    index += 1
                }
            }
        }
        return true
    }
    
    private func removeSpecial(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        
        return String(text.filter {okayChars.contains($0) })
    }
    
}


extension JoinVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
