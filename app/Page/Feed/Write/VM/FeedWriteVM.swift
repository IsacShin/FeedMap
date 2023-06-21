//
//  FeedWriteVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/21.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay
import CoreLocation

protocol FeedWriteVM {
    var input: FeedWriteVMInput { get }
    var output: FeedWriteVMOutput { get }
}

protocol FeedWriteVMInput {
    func addImg(imgList: [CommonPickerModel])
    func deleteImg(idx: Int)
    
    func regist(info: [String: Any], completion: @escaping () -> Void)
}

protocol FeedWriteVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var imgList: BehaviorRelay<[CpWriteSubVDPModel]?> { get }
    var success: BehaviorRelay<Bool?> { get }
}

final class FeedWriteVMImpl: NSObject, FeedWriteVM, FeedWriteVMInput, FeedWriteVMOutput {
    var input: FeedWriteVMInput {
        return self
    }
    
    var output: FeedWriteVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - output
    var error = BehaviorRelay<Error?>(value: nil)
    var imgList = BehaviorRelay<[CpWriteSubVDPModel]?>.init(value: nil)
    var success = BehaviorRelay<Bool?>(value: nil)
    
    // MARK: - input
    private func fileUploadWork() -> Observable<[String]>{

        var resultOBS = Observable.just([String]())

//        if let imgList = self.imgList.value,
//           imgList.count > 0 {
//            // 이미지 파일 있을 때
//            let dataList = imgList.compactMap { origin -> WDDUploadFile? in
//
//                guard let imgData = origin.img?.jpegData(compressionQuality: 0.8),
//                      let name = origin.name else{
//                    return nil
//                }
//                let resultValue = WDDUploadFile(data: imgData, fileName: name)
//
//                return resultValue
//            }
//
//            resultOBS = GlobalFunctionManager.shared.uploadFile(type: .qna, dataList: dataList)
//                .flatMap{ rList -> Observable<[String]> in
//
//                    let fileUrlList = rList.compactMap{ origin -> String? in
//                        return origin.uploadedURL
//                    }
//                    return .just(fileUrlList)
//                }
//        }

        return resultOBS
    }
    
    func regist(info: [String: Any], completion: @escaping () -> Void){
        
    }
    
    func addImg(imgList: [CommonPickerModel]) {
        
        
        let newList = imgList.compactMap { origin -> CpWriteSubVDPModel in
            
            var resultValue = CpWriteSubVDPModel()
            resultValue.name = origin.fileName
            resultValue.img = origin.img
            
            return resultValue
        }
        
        var resultList = [CpWriteSubVDPModel]()
        if let uPrevList = self.imgList.value {
            resultList = uPrevList
        }
        
        
        let spareImgCnt = 3 - resultList.count
        
        if spareImgCnt > 0 {
            if spareImgCnt < newList.count {
                
                var newCnt = 0
                
                let newListLimit = newList.filter { _ -> Bool in
                    
                    if spareImgCnt > 0 {
                        return true
                    }
                    
                    newCnt += 1
                    return false
                }
                resultList.append(contentsOf: newListLimit)
            } else {
                resultList.append(contentsOf: newList)
            }
        }
        
        for ii in 0 ..< resultList.count {
            
            var temp = resultList[ii]
            temp.index = ii
            resultList[ii] = temp
        }
        
        self.imgList.accept(resultList)
    }
    
    func deleteImg(idx: Int) {
        
        guard var tempImgList = self.imgList.value else{
            return
        }
        guard tempImgList.count > idx else{
            return
        }
        tempImgList.remove(at: idx)
        
        // 순서 재정렬
        let newModel = tempImgList.enumerated().map { (newIdx, model) -> CpWriteSubVDPModel in
            
            var tempModel = model
            tempModel.index = newIdx
            return tempModel
        }
        
        self.imgList.accept(newModel)
    }
}
