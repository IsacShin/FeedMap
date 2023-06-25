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

protocol FeedVM {
    var input: FeedVMInput { get }
    var output: FeedVMOutput { get }
}

protocol FeedVMInput {
    
}

protocol FeedVMOutput {
    var error: BehaviorRelay<Error?> { get }

    var feedListData: BehaviorRelay<[FeedRawData]?> { get }
    func getFeedList(memId:String?, completion: (() -> Void)?)

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
    
    func getFeedList(memId:String?, completion: (() -> Void)?) {
        var param = [String:Any]()
        if let memId = memId {
            param.updateValue("memid", forKey: memId)
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
}
