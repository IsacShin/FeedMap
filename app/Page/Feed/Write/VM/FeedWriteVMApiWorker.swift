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
        
        let reqHeader = ApiUtils.makeHeader()
        
        return .create { emitter -> Disposable in
            
            AF.upload(multipartFormData: { mfd in
                for (index,fileData) in fileList.enumerated() {
                    
                    guard let img = fileData.img?.jpegData(compressionQuality: 1.0) else { return }
                    
                    mfd.append(img,
                               withName: "file\(index)",
                               fileName: "file\(index)",
                               mimeType: "image/jpeg")
                }
            },
                      to: reqURL,
                      method: .post,
                      headers: reqHeader)
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
}
