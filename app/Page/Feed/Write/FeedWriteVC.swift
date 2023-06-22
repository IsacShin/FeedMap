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
    
    @IBOutlet weak var addrLB: UILabel!
    @IBOutlet weak var addrContentLB: UILabel!
    
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTitleLB: UILabel!
    @IBOutlet weak var descTV: UITextView!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    @IBOutlet var imgColV: UICollectionView!
    @IBOutlet weak var imgSelectLB: UILabel!
    @IBOutlet weak var imgSelectSubLB: UILabel!
    
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
        self.titleTF.text = nil
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
        
        [self.descTitleLB, self.imgSelectLB, self.imgSelectSubLB, self.titleLB, self.addrLB, self.addrContentLB]
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
        
        self.titleTF.do {
            $0.placeholder = "제목을 입력해주세요"
            $0.delegate = self
            $0.font = .regular(size: 14)
            $0.textColor = .lightGray
            $0.backgroundColor = .clear
            $0.settingCloseToolBar()
        }
        
        self.imgColV.do{
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            $0.collectionViewLayout = layout
            $0.backgroundColor = .clear
            
            $0.rx.setDelegate(self).disposed(by: self.disposeBag)
            
            $0.register(.init(nibName: "ImgSelectColVCell", bundle: nil), forCellWithReuseIdentifier: ImgSelectColVCell.description())
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
        
        self.setKeyboardNotiHandler(constraint: self.keyboardConstraint, constantValue: newHeight - 60, disposeBag: self.disposeBag, superView: self.view)
        
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
                self.vm.input.regist(info: [String : Any]()) {
                    print("업로드 완료")
                }
            })
            .disposed(by: self.disposeBag)
        
        self.imgColV
            .rx
            .itemSelected
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: { [weak self] idx in
                guard let self = self else {
                    return
                }
                self.imgColV.deselectItem(at: idx, animated: false)
                
                guard let list = self.vm.output.imgDataList.value else {
                    return
                }
                let cellData = list[idx.row]

                if cellData.img == nil {

                    let fList = list.filter {
                        $0.img == nil
                    }
                    let cnt = fList.count
                    
                    CommonPickerManager.shared.showYpAlbum(maxCount: cnt) { [weak self] sModelList in
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

                } else {
                    self.vm.input.deleteImage(idx: idx.row)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindOutputs() {
        let output = self.vm.output
        
        output
            .imgDataList
            .asDriver()
            .compactMap {
                $0
            }
            .drive(self.imgColV.rx.items(cellIdentifier: ImgSelectColVCell.description(), cellType: ImgSelectColVCell.self)) { _, cellData, cell in
                
                cell.mapCellData(pCellData: cellData)
                
            }
            .disposed(by: self.disposeBag)
        
        output
            .addressStr
            .asDriver()
            .compactMap {
                $0
            }
            .drive(self.addrContentLB.rx.text)
            .disposed(by: self.disposeBag)

    }
}

extension FeedWriteVC: UITextViewDelegate, UITextFieldDelegate {
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


extension FeedWriteVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var resultValue = CGSize.zero
        
        let inset: CGFloat = 20
        let space: CGFloat = 3
        
        let cellWidth = (SCREEN_WIDTH - (inset * 2) - (space * 3)) / 4
        let cellHeight: CGFloat = self.imgColV.frame.height
        
        resultValue = .init(width: cellWidth, height: cellHeight)
        
        return resultValue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var resultValue = UIEdgeInsets.zero
        
        resultValue = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        return resultValue
        
    }
    
}
