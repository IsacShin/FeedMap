//
//  MapVMApiWorker.swift
//  app
//
//  Created by 신이삭 on 2023/06/20.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

final class MapVMApiWorker {
    func getAddrGeocode(info: [String: Any]) -> Observable<GeocodeRawData> {
        guard let reqURL = ApiUtils.makeUrl("https://maps.googleapis.com/maps/api/geocode/json") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<GeocodeRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }
                
                var rawData: GeocodeRawData?
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
    
    func getFeedList(info: [String: Any]) -> Observable<FeedListRawData> {
        guard let reqURL = ApiUtils.makeUrl("/getFeedList.do") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<FeedListRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }
                
                var rawData: FeedListRawData?
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
