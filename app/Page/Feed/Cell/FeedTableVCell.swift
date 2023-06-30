//
//  FeedTableVCell.swift
//  app
//
//  Created by 신이삭 on 2023/06/24.
//

import Foundation
import UIKit
import ImageSlideshow
import Kingfisher
import RxSwift
import RxCocoa

final class FeedTableVCell: UITableViewCell {
    
    @IBOutlet var feedLBList: [UILabel]!
    @IBOutlet weak var profileImgV: UIImageView!
    @IBOutlet weak var profileV: UIView!
    @IBOutlet weak var idLB: UILabel!
    @IBOutlet weak var slideV: ImageSlideshow!
    
    @IBOutlet weak var addressLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var commentLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var contentV: UIView!
    
    @IBOutlet weak var lineV: UIView!
    @IBOutlet weak var contentVHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var declareBTN: UIButton!
    
    
    @IBOutlet weak var feedSTV: UIStackView!
    
    private var imgUrl = BehaviorRelay<URL?>(value: nil)
    
    private var imageInputs: [KingfisherSource] = []
    private var disposeBag = DisposeBag()
    public var tblV: UITableView?
    private var vm: FeedVM!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.settingSubviews()
        self.bindUI()
        self.bindUserEvents()
    }
    
    private func bindUserEvents() {
        self.declareBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                let actionSheet = UIAlertController(title: "신고 사유를 선택해주세요.", message: "신고 사유에 맞지 않는 사유일 경우,\n해당 신고는 처리되지 않습니다.\n신고 누적 횟수가 3회 이상일 경우 유저는 피드작성을 하실 수 없습니다.", preferredStyle: .actionSheet)
                self.declareBottomSheet(actionSheet: actionSheet) { reason in
                    guard let memid = UDF.string(forKey: "memId") else { return }
                    var param = [String:Any]()
                    param.updateValue(self.tag, forKey: "feedid")
                    param.updateValue(memid, forKey: "reporter")
                    param.updateValue(reason, forKey: "reason")
                    CommonLoading.shared.show()
                    self.vm.input.insertReport(info: param) {
                        actionSheet.dismiss(animated: true)
                        CommonLoading.shared.hide()
                    }
                    
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindUI() {
        let imgUrl = self.imgUrl
            .compactMap {
                $0
            }
            
        let img = imgUrl
            .flatMap { url -> Observable<UIImage?> in
                
                return ImageUtils.urlToImage(url: url)
                
            }
            .compactMap {
                $0
            }
        
        img
            .compactMap { rImg -> CGFloat? in

                let imgVWidth: CGFloat = SCREEN_WIDTH * 0.8

                var imgVHeight = imgVWidth / rImg.size.width * rImg.size.height
                let maxSlideHeight: CGFloat = 550
                if imgVHeight > maxSlideHeight {
                    imgVHeight = maxSlideHeight
                }
                return imgVHeight
            }
            .asDriver(onErrorJustReturn: .zero)
            .drive(onNext: {[weak self] height in
                guard let tbl = self?.tblV else { return }
                
                tbl.beginUpdates()
                self?.contentVHeightConst.constant = height
                tbl.endUpdates()
            })
//            .drive(self.contentVHeightConst.rx.constant)
            .disposed(by: self.disposeBag)
        
    }
    
    private func settingSubviews(){
        self.backgroundColor = DARK_COLOR
        self.contentV.do {
            $0.backgroundColor = .clear
        }
        
        self.feedLBList
            .compactMap {
                $0
            }
            .forEach {
                $0.textColor = .white
            }
        
        self.profileV.do {
            $0.layer.cornerRadius = $0.frame.width / 2
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 1
            
            $0.clipsToBounds = true
        }
        
        self.addressLB.do {
            $0.font = .regular(size: 14)
        }
        
        self.titleLB.do {
            $0.font = .bold(size: 18)
        }
        
        self.commentLB.do {
            $0.font = .regular(size: 16)
        }
        
        self.dateLB.do {
            $0.font = .regular(size: 12)
        }
        
        self.slideV.do {
            $0.zoomEnabled = true
            $0.backgroundColor = .black
            $0.delegate = self
        }
        
    }

    private func resetData(){
        self.addressLB.text = nil
        self.titleLB.text = nil
        self.commentLB.text = nil
        self.dateLB.text = nil
        self.idLB.text = nil
        self.profileImgV.image = nil
        self.imageInputs.removeAll()
        self.declareBTN.isHidden = false
    }
    
    public func mapCellData(pCellData: FeedRawData){
        
        self.resetData()
        
        if let id = pCellData.memid {
            self.idLB.text = id
            if let myId = UDF.string(forKey: "memId") {
                if id == myId {
                    self.declareBTN.isHidden = true
                    if let pUrl = UDF.string(forKey: "profileImg") {
                        guard let url = URL(string: pUrl) else { return }
                        self.profileImgV.kf.setImage(with: url)
                    } else {
                        let img = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
                        self.profileImgV.image = img
                        self.profileImgV.tintColor = .black
                    }
                } else {
                    self.declareBTN.isHidden = false
                    let img = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
                    self.profileImgV.image = img
                    self.profileImgV.tintColor = .black
                }
            }
        }
        
        if let img1 = pCellData.img1,
           let kImg = KingfisherSource(urlString: img1) {
            guard let img1Url = URL(string: img1) else { return }
            self.imgUrl.accept(img1Url)
            self.imageInputs.append(kImg)
        }
        
        if let img2 = pCellData.img2,
           let kImg = KingfisherSource(urlString: img2) {
            self.imageInputs.append(kImg)
        }
        
        if let img3 = pCellData.img3,
           let kImg = KingfisherSource(urlString: img3) {
            self.imageInputs.append(kImg)
        }
        
        if self.imageInputs.count > 0 {
            self.slideV.do {
                $0.setImageInputs(self.imageInputs)
                $0.contentScaleMode = .scaleAspectFill
                $0.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
            }
        }
        
        if let addr = pCellData.addr {
            self.addressLB.text = addr
        }
        
        if let title = pCellData.title {
            self.titleLB.text = title
        }
        
        if let comment = pCellData.comment {
            self.commentLB.text = comment
        }
        
        if let date = pCellData.date {
            self.dateLB.text = date.wddSimpleDateForm()
        }
        
    }
    
    private func declareBottomSheet(actionSheet: UIAlertController, handler: ((String)->Void)?) {
        
        
        let option0 = UIAlertAction(title: "부적절한 콘텐츠", style: .default) { (_) in
            handler?("부적절한 콘텐츠")
        }
        
        let option1 = UIAlertAction(title: "상업적 광고", style: .default) { (_) in
            handler?("상업적 광고")
        }
        
        let option2 = UIAlertAction(title: "음란물", style: .default) { (_) in
            handler?("음란물")
        }
        
        let option3 = UIAlertAction(title: "폭력성", style: .default) { (_) in
            handler?("폭력성")
        }
        
        let option4 = UIAlertAction(title: "기타", style: .default) { (_) in
            self.showAlertWithTextField { reason in
                handler?(reason)
            }
            
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (_) in
            actionSheet.dismiss(animated: true)
        }
        
        actionSheet.addAction(option0)
        actionSheet.addAction(option1)
        actionSheet.addAction(option2)
        actionSheet.addAction(option3)
        actionSheet.addAction(option4)
        actionSheet.addAction(cancel)
        
        UIApplication.topViewController()?.present(actionSheet, animated: true)
    }
    
    private func showAlertWithTextField(completion: ((String)->Void)?) {
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "신고 내용을 입력해주세요"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "전송", style: .default) { (_) in
            guard let textField = alertController.textFields?.first else { return }
            if let enteredText = textField.text {
                if enteredText != "" {
                    completion?(enteredText)
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        UIApplication.topViewController()?.present(alertController, animated: true)
    }
    
    public func mapVM(vm: FeedVM) {
        self.vm = vm
    }
}

extension FeedTableVCell: ImageSlideshowDelegate {
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        guard let imgUrl = imageSlideshow.images[page] as? KingfisherSource else {
            return
        }
        let url = imgUrl.url
        self.imgUrl.accept(url)
    }
    
   
}
