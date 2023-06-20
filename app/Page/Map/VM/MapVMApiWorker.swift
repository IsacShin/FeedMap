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
        
        guard let address = info["addr"] as? String else { return .error(RxError.unknown) }
        
        var param = [
            "address" : address,
            "key" : GMAP_KEY
        ]
        
        return RxAlamofire.requestData(.get, reqURL, parameters: param, encoding: URLEncoding.default, headers: nil)
            .flatMapLatest { arg -> Observable<GeocodeRawData> in
                
                if arg.0.statusCode != 200 {
                    return .error(RxError.unknown)
                }
                
                var rawData: GeocodeRawData?
                do{
                    rawData = try .init(data: arg.1)
                } catch let uError {
                    return .error(uError)
                }
                guard let uData = rawData else{
                    return .error(RxError.unknown)
                }
                return .just(uData)
                
            }
    }
}
