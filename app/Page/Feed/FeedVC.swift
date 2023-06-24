//
//  FeedVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit

class FeedVC: BaseVC {
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var morIMG: UIImageView!
    @IBOutlet weak var moreBTN: UIButton!
    
    private var vm: FeedVM!
    convenience init(vm: FeedVM?) {
        self.init(nibName: "Feed", bundle: nil)
        guard let vm = vm else { return }
        self.vm = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingSubviews()
        self.bindUI()
        self.bindUserEvents()
        self.bindOutputs()
    }
    
    private func settingSubviews() {
        self.view.backgroundColor = DARK_COLOR
        
        self.titleLB.do {
            $0.font = .bold(size: 20)
            $0.textColor = .white
        }
        
        self.morIMG.do {
            let img = UIImage(named: "more (1)")?.withRenderingMode(.alwaysTemplate)
            $0.image = img
            $0.tintColor = .white
        }
    }
    
    private func bindUI() {
        
    }
    
    private func bindUserEvents() {
        
    }
    
    private func bindOutputs() {
        
    }
    
}
