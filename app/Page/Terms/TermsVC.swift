//
//  TermsVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/25.
//

import UIKit

class TermsVC: BaseVC {
    
    
    @IBOutlet weak var privarcyTermsBTN: UIButton!
    @IBOutlet weak var locationTermsBTN: UIButton!
    @IBOutlet weak var serviceTermsBTN: UIButton!
    @IBOutlet weak var pImgV: UIImageView!
    @IBOutlet weak var lImgV: UIImageView!
    @IBOutlet weak var sImgV: UIImageView!
    
    convenience init() {
        self.init(nibName: "Terms", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingSubviews()
        self.bindUserEvents()
    }
    
    private func settingSubviews() {
        self.navigationItem.title = "약관 및 정책"
        self.naviBarHidden = false
        self.view.backgroundColor = DARK_COLOR
        
        [self.lImgV, self.pImgV, self.sImgV]
            .compactMap { $0 }
            .forEach {
                let img = UIImage(named: "btnRightArrow01")?.withRenderingMode(.alwaysTemplate)
                $0.image = img
                $0.tintColor = .white
            }

    }
    
    private func bindUserEvents() {
        self.privarcyTermsBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                let url = DOMAIN + "/terms.do"
                CommonNav.moveBaseWebVC(requestUrl: url)
            })
            .disposed(by: self.disposeBag)
        
        self.locationTermsBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                let url = DOMAIN + "/locationTerms.do"
                CommonNav.moveBaseWebVC(requestUrl: url)
            })
            .disposed(by: self.disposeBag)
        
        self.serviceTermsBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                let url = DOMAIN + "/serviceTerms.do"
                CommonNav.moveBaseWebVC(requestUrl: url)
            })
            .disposed(by: self.disposeBag)
    }

}
