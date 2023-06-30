//
//  LoginVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit

class LoginVC: BaseVC {

    @IBOutlet weak var scrV: UIScrollView!
    @IBOutlet var contentV: UIView!
    
    @IBOutlet weak var backBTN: UIButton!
    
    @IBOutlet weak var gooleBTN: UIButton!
    @IBOutlet weak var appleBTN: UIButton!
    
    @IBOutlet weak var loginLB: UILabel!
    @IBOutlet weak var loginBTN: UIButton!
    
    @IBOutlet weak var joinLB: UILabel!
    @IBOutlet weak var joinBTN: UIButton!
    
    @IBOutlet weak var findLB: UILabel!
    @IBOutlet weak var findBTN: UIButton!
    
    private var vm: LoginVM!
    convenience init(vm: LoginVM?) {
        self.init(nibName: "Login", bundle: nil)
        guard let vm = vm else { return }
        self.vm = vm
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.organizeSubviews()
        self.settingsSubviews()
        self.bindUI()
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
        self.scrV.do {
            $0.backgroundColor = .clear
            $0.keyboardDismissMode = .onDrag
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        self.view.backgroundColor = DARK_COLOR
        
        [self.loginLB, self.joinLB]
            .compactMap {
                $0
            }
            .forEach {
                $0.font = .regular(size: 17)
            }
        
        self.findLB.do {
            $0.font = .regular(size: 14)
            $0.textColor = .white
        }
    }
    
    private func bindUI() {
        
    }
    
    private func bindUserEvents() {
        self.gooleBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                UserManager.shared.google()
            })
            .disposed(by: self.disposeBag)
        
        self.appleBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                UserManager.shared.apple()
            })
            .disposed(by: self.disposeBag)
        
        self.loginBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                CommonNav.moveIdLoginVC()
            })
            .disposed(by: self.disposeBag)
        
        self.joinBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                CommonNav.moveJoinVC()
            })
            .disposed(by: self.disposeBag)
        
        self.findBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindOutputs() {
        
    }

}
