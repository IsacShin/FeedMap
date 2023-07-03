//
//  FeedWriteVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import UIKit
import RxSwift
import RxRelay

enum FeedPageType {
    case insert
    case update
}

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
    
    @IBOutlet weak var deleteBTN: UIButton!
    @IBOutlet weak var deleteLB: UILabel!
    @IBOutlet weak var deleteV: UIView!
    
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
            $0.contentInset = .init(top: 0, left: 0, bottom: 130, right: 0)
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
        
        self.deleteLB.do {
            $0.font = .regular(size: 14)
            $0.textColor = .red
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
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.titleTF, dpBag: self.disposeBag, flexibleValue: -100)
        self.settingScrVAutoScrollToTargetV(scrV: self.scrV, targetV: self.descTV, dpBag: self.disposeBag, flexibleValue: -100)
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
                self.tryRequest()
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
                    
                    CommonPickerManager.shared.showYpAlbum(maxCount: 3) { [weak self] sModelList in
                        guard let self = self else {
                            return
                        }
                        
                        let cList = sModelList.compactMap { origin -> ImgSelectColVCellDPModel? in
                            guard let name = origin.fileName else {
                                return nil
                            }
                            var rImg = origin.img
                            let imgVWidth: CGFloat = SCREEN_WIDTH * 0.8
                            if let maxHeight = sModelList.filter({ $0.img != nil }).map({ $0.img.size.height }).max() {
                                var imgVHeight = imgVWidth / rImg.size.width * maxHeight
                                let maxSlideHeight: CGFloat = 550
                                if imgVHeight > maxSlideHeight {
                                    imgVHeight = maxSlideHeight
                                }

                                if let resizeImg = self.resizeImage(image: rImg, newSize: CGSize(width: imgVWidth, height: imgVHeight)) {
                                    rImg = resizeImg
                                }
                            }
                            return .init(img: rImg, fileName: name)
                        }
                        self.vm.input.addImage(imgList: cList)
                    }

                } else {
                    self.vm.input.deleteImage(idx: idx.row)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.deleteBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                
                CommonAlert.showConfirmType(vc: self, message: "작성된 피드를 삭제하시겠습니까?" ,cancelTitle: "확인", completeTitle: "취소", {
                    CommonLoading.shared.show()
                    self.vm.input.delete {
                        CommonLoading.shared.hide()
                    }
                }, nil)
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
        
        output
            .success
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] result in
                guard let self = self else { return }
                if result == true {
                    CommonAlert.showAlertType(vc: self, message: "등록되었습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    CommonAlert.showAlertType(vc: self, message: "문제가 발생하였습니다.\n다시 시도해주세요.", nil)
                }
            })
            .disposed(by: self.disposeBag)
        
        output
            .deleteSuccess
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] result in
                guard let self = self else { return }
                if result == true {
                    CommonAlert.showAlertType(vc: self, message: "삭제되었습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    CommonAlert.showAlertType(vc: self, message: "문제가 발생하였습니다.\n다시 시도해주세요.", nil)
                }
            })
            .disposed(by: self.disposeBag)
        
        output.feedListData
            .asDriver()
            .compactMap {
                $0?.first
            }
            .drive(onNext: {[weak self] data in
                guard let self = self else { return }
                self.addrContentLB.text = data.addr
                self.descTV.text = data.comment
                self.titleTF.text = data.title
                self.vm.output.feedIdx.accept(data.id)
                
            })
            .disposed(by: self.disposeBag)
        
        output.pageType
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] type in
                if type == .insert {
                    self?.deleteV.isHidden = true
                } else {
                    self?.deleteV.isHidden = false
                }
            })
            .disposed(by: self.disposeBag)

    }
    
    private func downloadImg(urlStr: String, completion: ((UIImage)->Void)?) {
        guard let imageURL = URL(string: urlStr) else {
            return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                print("이미지 다운로드 오류: \(error.localizedDescription)")
                return
            }
            
            if let imageData = data, let image = UIImage(data: imageData) {
                // 다운로드된 이미지를 UIImage로 변환 성공
                // 변환된 UIImage를 사용하여 UI 업데이트 등을 수행할 수 있습니다.
                completion?(image)
            } else {
                print("이미지 변환 오류")
                return
            }
        }

        dataTask.resume()
    }
    
    private func tryRequest(){
     
        self.view.endEditing(true)
        
        guard var info = self.assembleData() else {
            return
        }
        
        CommonLoading.shared.show()
        self.completeBTN.isUserInteractionEnabled = false
        self.vm.input.regist(info: info) {
            CommonLoading.shared.hide()
            self.completeBTN.isUserInteractionEnabled = true
        }
        
    }
    
    private func assembleData() -> [String: Any]? {
        
        var resultValue = [String: Any]()
        
        //title, addr, comment
        guard let title = self.titleTF.text,
              title != "" else {
            CommonAlert.showAlertType(vc: self, message: "제목을 입력해주세요.", nil)
            return nil
        }
        
        guard let comment = self.descTV.text,
              comment != "내용을 입력하세요",
              comment != "" else {
            CommonAlert.showAlertType(vc: self, message: "내용을 입력해주세요.", nil)
            return nil
        }
        
        guard let img = self.vm.output.imgDataList.value?.first?.img else {
            CommonAlert.showAlertType(vc: self, message: "대표 이미지를 등록해주세요.", nil)
            return nil
        }

        guard let addr  = self.addrContentLB.text else { return nil }
        
        resultValue.updateValue(title, forKey: "title")
        resultValue.updateValue(addr, forKey: "addr")
        resultValue.updateValue(comment, forKey: "comment")
                
        return resultValue

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
