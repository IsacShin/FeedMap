//
//  ImgSelectColVCell.swift
//  app
//
//  Created by 신이삭 on 2023/06/22.
//

import UIKit

struct ImgSelectColVCellDPModel{
    var img: UIImage?
    var fileName: String?
}
final class ImgSelectColVCell: UICollectionViewCell {

    @IBOutlet weak var contentV: UIView!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var closeBTN: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.settingSubviews()
    }
    
    private func settingSubviews(){
        
        self.contentV.do{
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .init(hex: "f7f7f7")
        }
        self.imgV.do{
            $0.contentMode = .scaleAspectFill
        }
        self.closeBTN.do{
            $0.clipsToBounds = true
            $0.layer.cornerRadius = $0.frame.height * 0.5
            $0.isUserInteractionEnabled = false
        }
        
    }

    private func resetData(){
        
        self.imgV.image = nil
        self.imgV.isHidden = true
        self.closeBTN.isHidden = true
        
    }
    
    public func mapCellData(pCellData: ImgSelectColVCellDPModel){
        
        self.resetData()
        
        if let uImg = pCellData.img{
            self.imgV.image = uImg
            self.imgV.isHidden = false
            self.closeBTN.isHidden = false
        }
                
    }
}

