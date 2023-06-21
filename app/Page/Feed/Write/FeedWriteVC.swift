//
//  FeedWriteVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import UIKit
import RxSwift
import RxRelay

class FeedWriteVC: BaseVC {
    
    @IBOutlet weak var scrV: UIScrollView!
    @IBOutlet var contentV: UIView!
    
    @IBOutlet weak var completeBTN: BlackBTN!
    
    @IBOutlet weak var descTitleLB: UILabel!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var uploadTitleLB: UILabel!
    @IBOutlet weak var uploadBTN: UIButton!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileListSTV: UIStackView!
    @IBOutlet var fileListWrapper: UIView!
    
    let textViewPlaceHolder = "내용을 입력하세요"
    private var vm: FeedWriteVM!
    convenience init(vm: FeedWriteVM?) {
        self.init(nibName: "FeedWrite", bundle: nil)
        
        guard let vm = vm else { return }
        self.vm = vm
        self.hidesBottomBarWhenPushed = true
    }
    
    deinit {
        self.hidesBottomBarWhenPushed = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.organizeSubviews()
        self.initVState()
        self.settingSubviews()
        self.bindUI()
        self.bindUserEvents()
        self.bindOutputs()
    }
    
    private func organizeSubviews() {
        self.scrV.addSubview(self.contentV)
        self.contentV.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.width.equalTo(SCREEN_WIDTH)
            $0.height.equalToSuperview()
        }
    }
    
    private func initVState() {
        self.descTV.text = nil
        
        self.fileListSTV.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        self.fileListWrapper.isHidden = true
    }
    
    private func settingSubviews() {
        self.naviBarHidden = false
        self.navigationItem.title = "피드 등록"
        self.view.backgroundColor = DARK_COLOR
        
        self.scrV.do {
            $0.backgroundColor = .clear
            $0.keyboardDismissMode = .onDrag
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        }
        
        self.contentV.do {
            $0.backgroundColor = .clear
        }
        
        self.completeBTN.do {
            $0.titleLabel?.text = "완료"
            $0.tintColor = .white
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 12
        }
        
        [self.descTitleLB, self.uploadTitleLB]
            .compactMap {
                $0
            }
            .forEach {
                $0.font = .medium(size: 16)
                $0.textColor = .init(hex: "ffffff")
                $0.textAlignment = .left
            }

        self.descTV.do {
            $0.delegate = self
            $0.text = self.textViewPlaceHolder
            $0.font = .regular(size: 14)
            $0.textColor = .lightGray
            $0.backgroundColor = .clear
            $0.settingCloseToolBar()
        }
        
        self.uploadBTN.do {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
            $0.titleLabel?.font = .medium(size: 16)
            $0.setTitleColor(.init(hex: "ffffff"), for: .normal)
            $0.setTitleColor(.init(hex: "B8BDBB"), for: .disabled)
            $0.setBackgroundImage(.init(color: .init(hex: "dcdcdc")), for: .normal)
            $0.setBackgroundImage(.init(color: .init(hex: "EFF1EA")), for: .disabled)
        }
        
        self.fileListSTV.do {
            $0.backgroundColor = .clear
        }
        
        self.fileListWrapper.do {
            $0.backgroundColor = .clear
        }
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
        
    }
    
    private func bindUserEvents() {
        self.completeBTN
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
//                self.tryRegist()
                
            })
            .disposed(by: self.disposeBag)
        
        self.uploadBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: { [weak self] in
                
                guard let self = self else{
                    return
                }
                
                var cnt = 3
                if let uCurrentCnt = self.vm.output.imgList.value?.count{
                    cnt -= uCurrentCnt
                }
                
//                guard cnt > 0 else {
//                    CommonVManager.showMsg(msg: "첨부 가능한 파일 수는 5개입니다.")
//                    return
//                }
                CommonPickerManager.shared.showYpAlbum(maxCount: cnt) {[weak self] photoList in
                    guard let self = self else{
                        return
                    }
                    self.vm.input.addImg(imgList: photoList)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindOutputs() {
        let output = self.vm.output
        
        output
            .imgList
            .asDriver()
            .map { list -> Bool in
                
                var resultValue = true
                if let cnt = list?.count,
                   cnt > 0 {
                    resultValue = false
                }
                return resultValue
            }
            .drive(self.fileListWrapper.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        output
            .imgList
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: { [weak self] imgList in
                guard let self = self else {
                    return
                }
                
                self.fileListSTV.arrangedSubviews.forEach {
                    $0.removeFromSuperview()
                }
                
                imgList.forEach {data in
                    let subV = FeedWriteSubV()
                    self.fileListSTV.addArrangedSubview(subV)
                    subV.backgroundColor = .clear
                    subV.mapVm(vm: self.vm)
                    subV.mapData(data: data)
                    subV.snp.makeConstraints {
                        $0.height.equalTo(60)
                    }
                }
            })
            .disposed(by: self.disposeBag)
    }
}

extension FeedWriteVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = DARK_COLOR
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
}
