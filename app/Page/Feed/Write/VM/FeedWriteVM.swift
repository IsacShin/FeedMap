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

struct FeedWriteSeedInfo {
    var address: String?
}


protocol FeedWriteVMInput {
    func addImage(imgList: [ImgSelectColVCellDPModel])
    func deleteImage(idx: Int)
    
    func regist(info: [String: Any], completion: @escaping () -> Void)
}

protocol FeedWriteVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var imgDataList: BehaviorRelay<[ImgSelectColVCellDPModel]?> { get }
    var success: BehaviorRelay<Bool?> { get }
    
    var addressStr: BehaviorRelay<String?> { get }
}

final class FeedWriteVMImpl: FeedWriteVM, FeedWriteVMInput, FeedWriteVMOutput {
    var input: FeedWriteVMInput {
        return self
    }
    
    var output: FeedWriteVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    private let fWorker = FeedWriteVMApiWorker()
    // MARK: - output
    var error = BehaviorRelay<Error?>(value: nil)
    var success = BehaviorRelay<Bool?>(value: nil)
    var imgDataList = BehaviorRelay<[ImgSelectColVCellDPModel]?>(value: nil)
    var addressStr = BehaviorRelay<String?>(value: nil)
    
    private var seed: FeedWriteSeedInfo!
    init(seed: FeedWriteSeedInfo) {
        self.seed = seed
        self.makeImgList()
        self.bindParsing()
        
    }
    
    func bindParsing() {
        self.addressStr.accept(self.seed.address)
    }
    
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
    
    func addImage(imgList: [ImgSelectColVCellDPModel]){
        
        guard let prevList = self.imgDataList.value else {
            return
        }
        
        var resultList = prevList.filter {
            $0.img != nil
        }
        resultList.append(contentsOf: imgList)
        
        let remainCount = 3 - resultList.count
        
        if remainCount > 0 {
            
            let emptyList = (0 ..< remainCount).map { _ -> ImgSelectColVCellDPModel in
                return .init(img: nil, fileName: nil)
            }
            resultList.append(contentsOf: emptyList)
        }
        self.imgDataList.accept(resultList)
    }
    func deleteImage(idx: Int){
        
        guard var prevList = self.imgDataList.value else {
            return
        }
        
        guard idx < prevList.count else {
            return
        }
        guard prevList[idx].img != nil else {
            return
        }
        prevList.remove(at: idx)
        
        var resultList = prevList.filter {
            $0.img != nil
        }
        let remainCount = 3 - resultList.count
        
        if remainCount > 0 {
            
            let emptyList = (0 ..< remainCount).map { _ -> ImgSelectColVCellDPModel in
                return .init(img: nil, fileName: nil)
            }
            resultList.append(contentsOf: emptyList)
        }
        self.imgDataList.accept(resultList)
    }
    
    private func preImgWork() -> Observable<[String]> {
        
        if let list = self.imgDataList.value,
           list.count > 0{
            
            return self.fWorker.uploadFile(fileList: list)
                .flatMap { rData -> Observable<[String]> in
                    
                    guard let fileUrls = rData.fileUrls else { return .just(.init()) }
                    
                    return .just(fileUrls)
                    
                }
        } else {
            
            return .just(.init())
            
        }
        
    }
    
    func regist(info: [String: Any], completion: @escaping () -> Void){
        self.preImgWork()
            .subscribe(onNext: {[weak self] rData in
                print(rData)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeImgList(){
        
        let list = (0 ..< 4).map { _ -> ImgSelectColVCellDPModel in
            var resultValue = ImgSelectColVCellDPModel()
            resultValue.img = nil
            return resultValue
        }
        
        self.imgDataList.accept(list)
        
    }
}
