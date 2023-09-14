//
//  FeedWriteVMApiWorker.swift
//  app
//
//  Created by 신이삭 on 2023/06/22.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

final class FeedWriteVMApiWorker {
    func uploadFile(fileList: [ImgSelectColVCellDPModel]) -> Observable<FileUploadRawData>{
        
        let rawURL = "/upload2.do"
        guard let reqURL = ApiUtils.makeUrl(rawURL) else{
            return .error(RxError.unknown)
        }
                
        let header: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        return .create { emitter -> Disposable in
            
            AF.upload(multipartFormData: { mfd in
                for (index,fileData) in fileList.enumerated() {
                    
                    guard let img = fileData.img?.jpegData(compressionQuality: 0.1) else { return }
                    
                    mfd.append(img,
                               withName: "file\(index)",
                               fileName: "file\(index).jpeg",
                               mimeType: "image/jpeg")
                }
            },
                      to: reqURL,
                      method: .post,
                      headers: header)
            .uploadProgress { pr in
                print(pr.fractionCompleted.description)
            }
            .responseData { rResponse in
                
                switch rResponse.result{
                case .failure(let rError):
                    emitter.onError(rError)
                    return
                    
                case .success(let rData):
                    ApiUtils.showData(pData: rData)
                    
                    var rawData: FileUploadRawData?
                    do{
                        rawData = try .init(data: rData)
                    } catch let uError {
                        emitter.onError(uError)
                        return
                    }
                    
                    guard let uData = rawData else{
                        emitter.onError(RxError.unknown)
                        return
                    }
                    emitter.onNext(uData)
                    emitter.onCompleted()
                    return
                    
                }
            }
            return Disposables.create()
        }
    }
    
    func insertFeed(info: [String: Any]) -> Observable<FeedUpdateRawData> {
        guard let reqURL = ApiUtils.makeUrl("/insertFeed.do") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<FeedUpdateRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }

                var rawData: FeedUpdateRawData?
                do{
                    rawData = try .init(data: arg.1)
                } catch let uError {
                    return .error(uError)
                }
                guard let uData = rawData else{
                    return .error(RxError.noElements)
                }
                return .just(uData)
                
            }
    }
    
    func updateFeed(info: [String: Any]) -> Observable<FeedUpdateRawData> {
        guard let reqURL = ApiUtils.makeUrl("/updateFeed.do") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<FeedUpdateRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }
                
                var rawData: FeedUpdateRawData?
                do{
                    rawData = try .init(data: arg.1)
                } catch let uError {
                    return .error(uError)
                }
                guard let uData = rawData else{
                    return .error(RxError.noElements)
                }
                return .just(uData)
                
            }
    }
    
    func removeFeed(info: [String: Any]) -> Observable<FeedUpdateRawData> {
        guard let reqURL = ApiUtils.makeUrl("/removeFeed.do") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<FeedUpdateRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }
                
                var rawData: FeedUpdateRawData?
                do{
                    rawData = try .init(data: arg.1)
                } catch let uError {
                    return .error(uError)
                }
                guard let uData = rawData else{
                    return .error(RxError.noElements)
                }
                return .just(uData)
                
            }
    }
}
