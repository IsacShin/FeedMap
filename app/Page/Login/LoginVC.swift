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
    }
    
    private func bindOutputs() {
        
    }

}
