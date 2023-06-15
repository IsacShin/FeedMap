//
//  CommonPickerManaer.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import Photos
import PhotosUI
import RxSwift
import RxCocoa
import YPImagePicker
import Then

struct CommonPickerModel {
    var img:UIImage
    var fileName:String?
}

final class CommonPickerManager:NSObject {
    static let shared = CommonPickerManager()
    
    private let disposeBag = DisposeBag()
    private var systemPicker = UIImagePickerController()
    private var pickerClosure: (([CommonPickerModel]) -> Void)?
    private var ypPicker = YPImagePicker()
    
    public func showAlbum(maxCnt:Int = 1, completion:@escaping ([CommonPickerModel]) -> Void) {
        self.pickerClosure = completion
        
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = maxCnt
            config.filter = .any(of: [.images, .livePhotos]) // 이미지만 가능
            
            let picker = PHPickerViewController(configuration: config)
            picker.do {
                $0.delegate = self
                $0.modalPresentationStyle = .overFullScreen
            }
            
            UIApplication.topViewController()?.present(picker, animated: true)
        }else {
            guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true else {
                CommonAlert.showAlertType(vc: UIApplication.topViewController()!, message: "사용할 수 없는 기기 입니다.", nil)
                return
            }
            
            self.systemPicker.do {
                $0.delegate = self
                $0.sourceType = .photoLibrary
                $0.allowsEditing = false
                $0.mediaTypes = ["public.image"]
                $0.modalPresentationStyle = .overFullScreen
            }
            UIApplication.topViewController()?.present(systemPicker, animated: true)
            
        }
    }
    
    public func showYpAlbum(maxCount:Int, completion:@escaping ([CommonPickerModel]) -> Void) {
        self.pickerClosure = completion
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.isScrollToChangeModesEnabled = false
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.shouldSaveNewPicturesToAlbum = true
        
        config.wordings.warningMaxItemsLimit = "사진은 최대 \(maxCount)개 까지만 가능합니다."
        
        config.library.onlySquare = false
        config.library.mediaType = .photo
        config.library.maxNumberOfItems = 4
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.skipSelectionsGallery = true
        
        self.ypPicker = YPImagePicker(configuration: config)
        self.ypPicker.didFinishPicking { items, cancelled in
            guard cancelled == false else {
                self.ypPicker.dismiss(animated: true)
                return
            }
            var imgList = [UIImage]()
            for item in items {
                switch item {
                case .photo(let p):
                    imgList.append(p.image)
                default:
                    break
                }
            }
            
            var finalList = [CommonPickerModel]()
            for idx in 0..<imgList.count {
                let img = imgList[idx]
                let name = "image\(idx + 1).png"
                let model = CommonPickerModel(img: img, fileName: name)
                finalList.append(model)
            }
            
            self.ypPicker.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.pickerClosure?(finalList)
            }
        }
        
        UIApplication.topViewController()?.present(ypPicker, animated: true)

        
    }
    
    public func showCamera(maxCnt:Int = 1, completion:@escaping ([CommonPickerModel]) -> Void) {
        self.pickerClosure = completion
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true else {
            CommonAlert.showAlertType(vc: UIApplication.topViewController()!, message: "사용할 수 없는 기기 입니다.", nil)
            return
        }
        
        self.systemPicker.do {
            $0.delegate = self
            $0.sourceType = .camera
            $0.allowsEditing = false
            $0.mediaTypes = ["public.image"]
            $0.modalPresentationStyle = .overFullScreen
        }
        UIApplication.topViewController()?.present(systemPicker, animated: true)
    }
}

extension CommonPickerManager:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.originalImage] as? UIImage else {
            return
        }
        
        let imgUrl = info[.imageURL] as? URL
        var fileName = "image.png"
        if let last = imgUrl?.lastPathComponent {
            fileName = last
        }
        
        let result = CommonPickerModel(img: img, fileName: fileName)
        
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.pickerClosure?([result])
            self.pickerClosure = nil
        }
    }
}

extension CommonPickerManager:UINavigationControllerDelegate {}

extension CommonPickerManager:PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let ob = { (pData:PHPickerResult) -> Observable<CommonPickerModel> in
            let img = ImageUtils.pickerResultConvertToUIImage(result: pData)
            let name = ImageUtils.pickerResultConvertToMetaData(result: pData)
            
            return Observable.zip(img, name)
                .flatMap { arg -> Observable<CommonPickerModel> in
                    guard let img = arg.0 else { return .empty() }
                    return .just(CommonPickerModel(img: img, fileName: arg.1?.lastPathComponent))
                }
        }

    }
}
