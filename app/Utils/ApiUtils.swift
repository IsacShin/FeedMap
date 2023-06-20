//
//  ApiUtils.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import RxAlamofire
import Alamofire
import RxSwift


// MARK: - Helper functions for creating encoders and decoders
func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

final class ApiUtils {
    class func makeUrl(_ additionalURL: String) -> URL? {
        if additionalURL.contains("http") {
            return URL(string: additionalURL)
        }
        let url = DOMAIN + additionalURL
        return URL(string: url)
    }
    
    class func makeHeader() -> HTTPHeaders {
        var header = [String:String]()
        
        header["Content-Type"] = "application/json"
        header["appVer"] = APP_VER
        header["appId"] = APP_ID
        
        showJson(header)
        
        return HTTPHeaders(header)
    }
    
    class func makeError(resultMsg: String?, errCode: Int? = nil) -> NSError{
        
        var errDic = [String: Any]()
        errDic["result_msg"] = resultMsg
        
        var code = 0
        if let uCode = errCode{
            code = uCode
        }
        let rError = NSError(domain: "", code: code, userInfo: errDic)
        
        return rError
        
    }
    
    class func checkHttpStatusCode(_ response: HTTPURLResponse) -> NSError?{
        guard response.statusCode != 200 else{
            return nil
        }
        
        let rError = ApiUtils.makeError(resultMsg: "서버와의 통신중에 문제가 발생하였습니다. 조금 후에 다시 시도해주세요.")
        
        return rError
    }
    
    class func commonError(_ arg: (HTTPURLResponse, Data)) -> Error? {
        
        /// http errror
        print("status code = \(arg.0.statusCode), [\(String(describing: arg.0.url?.absoluteString))]")
        ApiUtils.showData(pData: arg.1)
        if var uError = self.checkHttpStatusCode(arg.0){
            uError = ApiUtils.makeError(resultMsg: "문제가 발생하였습니다.\n잠시후 다시 시도해주세요.", errCode: arg.0.statusCode)
            return uError
        }

        return nil
    }
    
    class func showJson(_ dic:[String:Any]) {
        guard let json = try? JSONSerialization.data(withJSONObject: dic, options: [.prettyPrinted]) else {
            return
        }
        
        guard let jsonTxt = String(bytes: json, encoding: String.Encoding.utf8) else {
            return
        }
        
        print()
        print(jsonTxt)
        print()
    }
    
    class func stringToJson(_ pData: String) -> [String: Any]?{
        guard let uData = pData.data(using: .utf8) else{
            return nil
        }
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: uData, options: .allowFragments) as? [String: Any]
            {
                return jsonArray
            } else {
                return nil
            }
        } catch  {
            return nil
        }
    }
    
    class func showData(pData: Data){
        guard let json = try? JSONSerialization.jsonObject(with: pData, options: []) as? [String: Any] else{
            self.showDataArray(pData: pData)
            return
        }
        self.showJson(json)
    }
    
    class func showDataArray(pData: Data) {
        guard let list = try? JSONSerialization.jsonObject(with: pData, options: []) as? [[String: Any]] else{
            return
        }
        print("[")
        for sub in list {
            self.showJson(sub)
            print(",")
        }
        print("]")
    }
}
