//
//  SplashVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

class SplashVC: BaseVC {
    
    @IBOutlet weak var splashImg: UIImageView!
    @IBOutlet weak var splashLB: UILabel!
    private let vm = SplashVMImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsSubviews()
        self.bindOutputs()
    }
    
    private func bindOutputs() {
        let output = self.vm.output
        
        output.nextAction
            .asDriver(onErrorJustReturn: .firstLaunch)
            .drive(onNext: {[weak self] state in
                guard let self = self else { return }
                switch state {
                case .firstLaunch:
                    self.startAnim(state: .firstLaunch)
                case .yetLaunch:
                    self.startAnim(state: .yetLaunch)
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    // MARK: - view cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initializeData()
    }
    
    // MARK: - private
    private var isFirst = true
    private func initializeData(){
        
        guard self.isFirst == true else{
            return
        }
        self.isFirst = false
        
        self.vm.input.startLaunch()
        
    }
    
    
    private func settingsSubviews() {
        self.view.backgroundColor = .darkGray
    }
    
    private func startAnim(state: LaunchState) {
        self.splashLB.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 1.0) {
                self.splashLB.alpha = 1.0
                self.view.layoutIfNeeded()
            } completion: { f in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if state == .firstLaunch {
                        CommonNav.moveAccessGuideVC()
                    } else {
                        guard let token = UDF.string(forKey: "idToken") else {
                            DispatchQueue.main.async {
                                NaviManager.shared.resetNavi {
                                    CommonNav.moveLoginVC()
                                }
                            }
                            return
                        }
                        
                        NaviManager.shared.resetNavi()
                        
                    }
                }
            }
        }
    }
    
}
