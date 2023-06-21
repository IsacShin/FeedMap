//
//  FeedWriteSubV.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import Foundation
import RxSwift
import RxRelay

struct CpWriteSubVDPModel {
    var img: UIImage?
    var name: String?
    var index: Int = 0
}

final class FeedWriteSubV: UIView {

    // MARK: - ibo
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var deleteLB: UILabel!
    @IBOutlet weak var borderV: UIView!
    @IBOutlet weak var deleteBTN: UIButton!
    
    private var subVIndex = -1
    private let disposeBag = DisposeBag()
    private var vm: FeedWriteVM!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    private func commonInit() {
        guard let uView = Bundle.main.loadNibNamed("FeedWriteSubV", owner: self, options: nil)?.first as? UIView else {
            return
        }
        
        self.addSubview(uView)
        uView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
        self.settingSubviews()
        self.bindUserEvents()
    }
    
    private func settingSubviews(){
        
        self.backgroundColor = DARK_COLOR
        
        self.nameLB.do {
            $0.font = .regular(size: 14)
            $0.textColor = .init(hex: "000000")
            $0.textAlignment = .left
        }
        
        self.deleteLB.do {
            $0.font = .regular(size: 12)
            $0.textColor = .init(hex: "F4223A")
            $0.textAlignment = .center
        }
        self.borderV.do{
            $0.backgroundColor = .init(hex: "f4223a")
        }
    }
    
    private func bindUserEvents() {
        
        self.deleteBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else {
                    return
                }
                
                self.vm.input.deleteImg(idx: self.subVIndex)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func resetData() {
        self.nameLB.text = nil
        self.subVIndex = -1
    }
    
    public func mapData(data: CpWriteSubVDPModel) {
        self.resetData()
        
        if let uName = data.name {
            self.nameLB.text = uName
        }
        self.subVIndex = data.index
        
    }
    
    public func mapVm(vm: FeedWriteVM) {
        self.vm = vm
    }
}
