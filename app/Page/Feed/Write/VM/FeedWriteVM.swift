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
    var location: CLLocation?
    var pageType: FeedPageType = .insert
}


protocol FeedWriteVMInput {
    func addImage(imgList: [ImgSelectColVCellDPModel])
    func deleteImage(idx: Int)
    
    func regist(info: [String: Any], completion: @escaping () -> Void)
    func delete(completion: @escaping () -> Void)
}

protocol FeedWriteVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var imgDataList: BehaviorRelay<[ImgSelectColVCellDPModel]?> { get }
    var success: BehaviorRelay<Bool?> { get }
    var deleteSuccess: BehaviorRelay<Bool?> { get }
    var pageType: BehaviorRelay<FeedPageType> { get }
    var addressStr: BehaviorRelay<String?> { get }
    var feedListData: BehaviorRelay<[FeedRawData]?> { get }
    var feedIdx: BehaviorRelay<Int?> { get }
    func getFeedList(loca:CLLocation?, completion: (() -> Void)?)

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
    var pageType = BehaviorRelay<FeedPageType>(value: .insert)
    var feedListData = BehaviorRelay<[FeedRawData]?>(value: nil)
    var feedListRawData = BehaviorRelay<FeedListRawData?>(value: nil)
    var feedIdx = BehaviorRelay<Int?>(value: nil)
    var deleteSuccess = BehaviorRelay<Bool?>(value: nil)
    private let mapWorker = MapVMApiWorker()

    private var seed: FeedWriteSeedInfo!
    init(seed: FeedWriteSeedInfo) {
        self.seed = seed
        self.makeImgList()
        self.bindParsing()
        if self.seed.pageType == .update {
            CommonLoading.shared.show()
            self.getFeedList(loca: seed.location) {
                CommonLoading.shared.hide()
            }
        }
    }
    
    func bindParsing() {
        self.addressStr.accept(self.seed.address)
        self.pageType.accept(self.seed.pageType)
        
        let feedList = self.feedListRawData
            .compactMap{ $0 }
        
        feedList
            .compactMap {
                $0.list
            }
            .bind(to: self.feedListData)
            .disposed(by: self.disposeBag)
    }
    
    func getFeedList(loca:CLLocation?, completion: (() -> Void)?) {
        guard let memId = UDF.string(forKey: "memId") else { return }
        var param: [String:Any] = [
            "memid" : memId,
            "type" : "all"
        ]
        
        if let loca = loca {
            let lat = String(format: "%.4f", Double(loca.coordinate.latitude))
            let lng = String(format: "%.4f", Double(loca.coordinate.longitude))
            param.updateValue(lat, forKey: "latitude")
            param.updateValue(lng, forKey: "longitude")
        }
        self.mapWorker.getFeedList(info: param)
            .subscribe(onNext: { [weak self] rData in

                guard let self = self else{
                    return
                }
                self.feedListRawData.accept(rData)

                
                }, onError: { [weak self] rError in

                guard let self = self else{
                    return
                }
                self.error.accept(rError)

            }, onDisposed: completion)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - input
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
    
    func regist(info: [String: Any], completion: @escaping () -> Void) {
        
        var param = info
        guard let loca = self.seed.location,
              let memid = UDF.string(forKey: "memId") else { return }
        let latitude = String(format: "%.4f", Double(loca.coordinate.latitude))
        let longitude = String(format: "%.4f", Double(loca.coordinate.longitude))
       
        param.updateValue(latitude, forKey: "latitude")
        param.updateValue(longitude, forKey: "longitude")
        param.updateValue(memid, forKey: "memid")
        
        self.preImgWork()
            .subscribe(onNext: { rData in
                for (i,item) in rData.enumerated() {
                    param.updateValue(item, forKey: "img\(i+1)")
                }
                if self.pageType.value == .insert {
                    self.fWorker.insertFeed(info: param)
                        .subscribe(onNext: { [weak self] rData in

                            guard let self = self else{
                                return
                            }
                            if rData.resultCode == 200 {
                                self.success.accept(true)
                            } else {
                                self.success.accept(false)
                            }

                            }, onError: { [weak self] rError in

                            guard let self = self else{
                                return
                            }
                            self.error.accept(rError)

                        }, onDisposed: completion)
                        .disposed(by: self.disposeBag)
                } else {
                    guard let id = self.feedIdx.value else { return }
                    param.updateValue(id, forKey: "id")
                    self.fWorker.updateFeed(info: param)
                        .subscribe(onNext: { [weak self] rData in

                            guard let self = self else{
                                return
                            }
                            if rData.resultCode == 200 {
                                self.success.accept(true)
                            } else {
                                self.success.accept(false)
                            }

                            }, onError: { [weak self] rError in

                            guard let self = self else{
                                return
                            }
                            self.error.accept(rError)

                        }, onDisposed: completion)
                        .disposed(by: self.disposeBag)
                }
                
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func delete(completion: @escaping () -> Void) {
        guard let id = self.feedIdx.value,
              let memid = UDF.string(forKey: "memId") else { return }
        
        var param: [String:Any] = [
            "memid" : memid,
            "id" : id
        ]
        
        self.fWorker.removeFeed(info: param)
            .subscribe(onNext: { [weak self] rData in

                guard let self = self else{
                    return
                }
                if rData.resultCode == 200 {
                    self.deleteSuccess.accept(true)
                } else {
                    self.deleteSuccess.accept(false)
                }

                }, onError: { [weak self] rError in

                guard let self = self else{
                    return
                }
                self.error.accept(rError)

            }, onDisposed: completion)
            .disposed(by: self.disposeBag)
    }
    
    private func makeImgList(){
        
        let list = (0 ..< 3).map { _ -> ImgSelectColVCellDPModel in
            var resultValue = ImgSelectColVCellDPModel()
            resultValue.img = nil
            return resultValue
        }
        
        self.imgDataList.accept(list)
        
    }
}
