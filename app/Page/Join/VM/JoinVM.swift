//
//  JoinVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/29.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

protocol JoinVM {
    var input: JoinVMInput { get }
    var output: JoinVMOutput { get }
}

protocol JoinVMInput {
    func addImage(imgList: [ImgSelectColVCellDPModel])
    func deleteImage(idx: Int)
    
    func regist(info: [String: Any], completion: @escaping () -> Void)
}

protocol JoinVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var imgDataList: BehaviorRelay<[ImgSelectColVCellDPModel]?> { get }
    var success: BehaviorRelay<Bool?> { get }
}

final class JoinVMImpl: JoinVM, JoinVMInput, JoinVMOutput {
    var input: JoinVMInput {
        return self
    }
    
    var output: JoinVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    private let fWorker = FeedWriteVMApiWorker()
    private let uWorker = UserApiWorker()
    
    var error = BehaviorRelay<Error?>(value: nil)
    var success = BehaviorRelay<Bool?>(value: nil)
    var imgDataList = BehaviorRelay<[ImgSelectColVCellDPModel]?>(value: nil)
    
    func addImage(imgList: [ImgSelectColVCellDPModel]){
 
        var resultList = [ImgSelectColVCellDPModel]()
        resultList.append(contentsOf: imgList)
        
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
        let remainCount = 1
        
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
        
        self.uWorker.getMemberId(info: info)
            .subscribe(onNext: { [weak self] mData in
                guard let self = self else{
                    return
                }
                
                if mData.list?.count ?? 0 > 0 {
                    guard let topVC = UIApplication.topViewController() else { return }
                    CommonAlert.showAlertType(vc: topVC, message: "이미 가입한 사용자 입니다.", nil)
                } else {
                    var param = info
                    
                    self.preImgWork()
                        .subscribe(onNext: { rData in
                            for (_,item) in rData.enumerated() {
                                param.updateValue(item, forKey: "profileUrl")
                            }
                            self.uWorker.insertMember(info: param)
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
                            
                            
                        })
                        .disposed(by: self.disposeBag)
                }
                
            })
            .disposed(by: self.disposeBag)
        
        
        
    }
}
