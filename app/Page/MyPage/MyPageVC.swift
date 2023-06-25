//
//  MyPageVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit
import Kingfisher

class MyPageVC: BaseVC {
    
    @IBOutlet weak var scrV: UIScrollView!
    @IBOutlet var contentV: UIView!
    
    @IBOutlet weak var profileImgWrapV: UIView!
    @IBOutlet weak var profileImgV: UIImageView!
    
    @IBOutlet weak var idLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet var termBTN: UIButton!
    @IBOutlet var versionBTN: UIButton!
    @IBOutlet var logoutBTN: UIButton!
    
    @IBOutlet weak var settingListV: UIView!
    @IBOutlet var settingLBList: [UILabel]!
    @IBOutlet var settingLBImg: [UIImageView]!
    
    @IBOutlet weak var setting1BTN: UIButton!
    @IBOutlet weak var setting2BTN: UIButton!
    
    private var vm: MyPageVM!
    convenience init(vm: MyPageVM?) {
        self.init(nibName: "MyPage", bundle: nil)
        guard let vm = vm else { return }
        self.vm = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.organizeSubviews()
        self.settingsSubviews()
        self.bindUserEvents()
        self.bindOutputs()
    }
    
    private func organizeSubviews(){
        self.scrV.addSubview(self.contentV)
        self.contentV.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.width.equalTo(SCREEN_WIDTH)
            $0.height.equalToSuperview()
        }
    }
    
    private func settingsSubviews() {
        self.view.backgroundColor = DARK_COLOR
        
        
        self.scrV.do {
            $0.backgroundColor = .clear
            $0.keyboardDismissMode = .onDrag
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        self.contentV.do {
            $0.backgroundColor = .clear
        }
        
        self.profileImgWrapV.do {
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = $0.frame.width / 2
            $0.clipsToBounds = true
        }
        
        self.profileImgV.do {
            if let pUrl = UDF.string(forKey: "profileImg") {
                guard let url = URL(string: pUrl) else { return }
                $0.kf.setImage(with: url)
            } else {
                let img = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
                $0.image = img
                $0.tintColor = .black
            }
        }
        
        self.idLB.do {
            $0.font = .regular(size: 18)
            $0.textColor = .white
            
            guard let id = UDF.string(forKey: "memId") else {
                return
            }
            
            $0.text = id
        }
        
        self.nameLB.do {
            $0.font = .regular(size: 18)
            $0.textColor = .white
            
            guard let name = UDF.string(forKey: "userName") else {
                return
            }
            
            $0.text = "\(name)님"
        }
        
        self.versionBTN.do {
            $0.setTitle("Ver.\(APP_VER)", for: .normal)
        }
        
        [self.termBTN, self.versionBTN, self.logoutBTN]
            .compactMap {
                $0
            }
            .forEach {
                $0.titleLabel?.font = .regular(size: 14)
                $0.setTitleColor(.init(hex: "dcdcdc"), for: .normal)
            }
        
        self.settingListV.do {
            $0.layer.cornerRadius = 16
        }
        
        self.settingLBList
            .compactMap {
                $0
            }
            .forEach {
                $0.font = .regular(size: 14)
            }
        
        self.settingLBImg
            .compactMap {
                $0
            }
            .forEach {
                let img = UIImage(named: "btnRightArrow01")?.withRenderingMode(.alwaysTemplate)
                $0.image = img
                $0.tintColor = .white
            }
        
    }
    
    private func bindUserEvents() {
        self.logoutBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                CommonAlert.showConfirmType(vc: self, message: "로그아웃 하시겠습니까?" ,cancelTitle: "확인", completeTitle: "취소", {
                    UserManager.shared.logout()
                }, nil)
            })
            .disposed(by: self.disposeBag)
        
        self.setting1BTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                CommonAlert.showAlertType(vc: self, message: "현재 버전은 \(APP_VER)버전 입니다." , nil)
            })
            .disposed(by: self.disposeBag)
        
        self.setting2BTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                CommonNav.moveTermsVC()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindOutputs() {
        
    }
        
}
