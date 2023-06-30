//
//  UserApiWorker.swift
//  app
//
//  Created by 신이삭 on 2023/06/30.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

final class UserApiWorker {
    
    func getMember(info: [String: Any]) -> Observable<UserListRawData> {
        guard let reqURL = ApiUtils.makeUrl("/getMember.do") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<UserListRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }

                var rawData: UserListRawData?
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
    
    func getMemberId(info: [String: Any]) -> Observable<UserListRawData> {
        guard let reqURL = ApiUtils.makeUrl("/getMemberId.do") else {
            return .error(RxError.unknown)
        }
        
        return RxAlamofire.requestData(.get, reqURL, parameters: info, encoding: URLEncoding.default, headers: ApiUtils.makeHeader())
            .flatMapLatest { arg -> Observable<UserListRawData> in
                print(reqURL)
                if arg.0.statusCode != 200 {
                    return .error(RxError.timeout)
                }

                var rawData: UserListRawData?
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
    
    func insertMember(info: [String: Any]) -> Observable<FeedUpdateRawData> {
        guard let reqURL = ApiUtils.makeUrl("/insertMember.do") else {
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
    
    func updateMember(info: [String: Any]) -> Observable<FeedUpdateRawData> {
        guard let reqURL = ApiUtils.makeUrl("/updateMember.do") else {
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
    
    func removeMember(info: [String: Any]) -> Observable<FeedUpdateRawData> {
        guard let reqURL = ApiUtils.makeUrl("/removeMember.do") else {
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
