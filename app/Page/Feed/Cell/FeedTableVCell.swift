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
    var imageInputs: [KingfisherSource] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.settingSubviews()
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
    }
    
    public func mapCellData(pCellData: FeedRawData){
        
        self.resetData()
        
        if let id = UDF.string(forKey: "memId") {
            self.idLB.text = id
        }
        
        if let pUrl = UDF.string(forKey: "profileImg") {
            guard let url = URL(string: pUrl) else { return }
            self.profileImgV.kf.setImage(with: url)
        } else {
            let img = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
            self.profileImgV.image = img
            self.profileImgV.tintColor = .black
        }
        
        if let img1 = pCellData.img1,
           let kImg = KingfisherSource(urlString: img1) {
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
                $0.contentScaleMode = .scaleAspectFit
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
}
