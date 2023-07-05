//
//  FeedVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/24.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay
import CoreLocation
import RxAlamofire
import Alamofire

protocol FeedVM {
    var input: FeedVMInput { get }
    var output: FeedVMOutput { get }
}

protocol FeedVMInput {
    func insertReport(info: [String: Any], completion: @escaping () -> Void)
}

protocol FeedVMOutput {
    var error: BehaviorRelay<Error?> { get }

    var feedListData: BehaviorRelay<[FeedRawData]?> { get }
    func getFeedList(memId:String?, type:String, completion: (() -> Void)?)

}

final class FeedVMImpl: FeedVM, FeedVMInput, FeedVMOutput {
    var input: FeedVMInput {
        return self
    }
    
    var output: FeedVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    
    var error = BehaviorRelay<Error?>(value: nil)
    var feedListData = BehaviorRelay<[FeedRawData]?>(value: nil)
    var feedListRawData = BehaviorRelay<FeedListRawData?>(value: nil)

    private let mapWorker = MapVMApiWorker()

    init() {
        self.bindParsing()
    }
    
    private func bindParsing() {
        
       
        let feedList = self.feedListRawData
            .compactMap{ $0 }
        
        feedList
            .compactMap {
                $0.list
            }
            .bind(to: self.feedListData)
            .disposed(by: self.disposeBag)
        
    }
    
    func getFeedList(memId:String?, type:String = "all", completion: (() -> Void)?) {
        var param = [String:Any]()
        if let memId = memId {
            param.updateValue(memId, forKey: "memid")
        }
        param.updateValue(type, forKey: "type")
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
    
    func insertReport(info: [String: Any], completion: @escaping () -> Void) {
        
        self.mapWorker.insertReport(info: info)
            .subscribe(onNext: { [weak self] rData in

                guard let self = self else {
                    return
                }
                
                guard let topVC = UIApplication.topViewController() else { return }
                if rData.resultCode == 200 {
                    
                    CommonAlert.showAlertType(vc: topVC, message: "신고 내용이 접수되었습니다.\n검토까지는 최대 24시간 소요됩니다.", {
                        guard let memid = UDF.string(forKey: "memId") else { return }
                        CommonLoading.shared.show()
                        self.getFeedList(memId: memid) {
                            CommonLoading.shared.hide()
                        }
                    })
                } else if rData.resultCode == 300 {
                    CommonAlert.showAlertType(vc: topVC, message: "이미 신고한 피드 입니다.", nil)
                } else {
                    CommonAlert.showAlertType(vc: topVC, message: "오류가 발생했습니다.\n다시 시도해주세요.", nil)
                }

                }, onError: { [weak self] rError in

                guard let self = self else{
                    return
                }
                self.error.accept(rError)

            }, onDisposed: completion)
            .disposed(by: self.disposeBag)
    }
}
