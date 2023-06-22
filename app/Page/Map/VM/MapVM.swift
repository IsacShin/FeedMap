//
//  MapVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/19.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay
import CoreLocation

protocol MapVM {
    var input: MapVMInput { get }
    var output: MapVMOutput { get }
}

protocol MapVMInput {
    func initializeData(completion: @escaping () -> Void)
    func checkCurrentLocationAuth(_ completion: (() -> Void)?)
    var cLocation: BehaviorRelay<CLLocation?> { get }
}

protocol MapVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var currentLocation: BehaviorRelay<CLLocation?> { get }
    var isCheckCurrentLocationFail: BehaviorRelay<Bool?> { get }
    var gResultData: BehaviorRelay<AddrRawData?> { get }
    var feedListData: BehaviorRelay<[FeedRawData]?> { get }
    var moveLocation: BehaviorRelay<CLLocation?> { get }
    var centerAddr: BehaviorRelay<String?> { get }
    
    func getFeedList(loca:CLLocation?, completion: (() -> Void)?)
}

final class MapVMImpl: NSObject, MapVM, MapVMInput, MapVMOutput {
    var input: MapVMInput {
        return self
    }
    
    var output: MapVMOutput {
        return self
    }
    
    private let disposeBag = DisposeBag()
    
    var error = BehaviorRelay<Error?>(value: nil)
    var currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    var isCheckCurrentLocationFail = BehaviorRelay<Bool?>(value: nil)
    var cLocation = BehaviorRelay<CLLocation?>(value: nil)
    var cAddress = BehaviorRelay<String?>(value: nil)
    var gResultData = BehaviorRelay<AddrRawData?>(value: nil)
    var feedListData = BehaviorRelay<[FeedRawData]?>(value: nil)
    
    var gResultRawData = BehaviorRelay<GeocodeRawData?>(value: nil)
    var feedListRawData = BehaviorRelay<FeedListRawData?>(value: nil)
    var moveLocation = BehaviorRelay<CLLocation?>(value: nil)
    var centerAddr = BehaviorRelay<String?>(value: nil)
    private var clManager: CLLocationManager?
    private var currentHandler: (() -> Void)?
    private let mapWorker = MapVMApiWorker()

    override init() {
        super.init()
        self.bindParsing()
        self.settingNotiReceiver()
    }
    
    func settingNotiReceiver() {
        let notiCenter = NotificationCenter.default.rx
        
        notiCenter
            .notification(Notification.Name("addrInfo"))
            .subscribe(onNext: {[weak self] noti in
                guard let self = self else { return }
                guard let userInfo = noti.userInfo,
                      let jibunAddress = userInfo["jibunAddress"] as? String,
                      let roadAddress = userInfo["roadAddress"] as? String,
                      let zonecode = userInfo["zonecode"] as? String else { return }
                
                let param = [
                    "address" : jibunAddress,
                    "key" : GMAP_KEY
                ]
                
                self.getAddrGeocode(param: param)
            })
    }
    
    func getAddrGeocode(param: [String: Any]) {
        self.mapWorker.getAddrGeocode(info: param)
            .subscribe(onNext: { [weak self] rData in

                guard let self = self else{
                    return
                }
                self.gResultRawData.accept(rData)
            },
                       onError: { [weak self] rError in

                guard let self = self else{
                    return
                }
                self.error.accept(rError)

            })
            .disposed(by: self.disposeBag)
    }
    
    func getFeedList(loca:CLLocation?, completion: (() -> Void)?) {
        guard let memId = UDF.string(forKey: "memId") else { return }
        var param: [String:Any] = [
            "memid" : memId
        ]
        
        if let loca = loca {
            let lat: Double = Double(loca.coordinate.latitude)
            let lng: Double = Double(loca.coordinate.longitude)
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
    
    func initializeData(completion: @escaping () -> Void) {
        self.checkCurrentLocationAuth(completion)
    }
    
    private func bindParsing() {
        
        let gResultList = self.gResultRawData
            .compactMap{ $0 }
        
        gResultList
            .compactMap {
                $0.results?.first
            }
            .bind(to: self.gResultData)
            .disposed(by: self.disposeBag)
        
        self.gResultData
            .compactMap {
                $0?.geometry?.location
            }
            .bind(onNext: {[weak self] data in
                guard let self = self else { return }
                guard let lat = data.lat,
                      let lng = data.lng else { return }
                        
                let location = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
                
                self.moveLocation.accept(location)
            })
            .disposed(by: self.disposeBag)
        
        self.gResultData
            .compactMap {
                $0?.formatted_address
            }
            .bind(onNext: {[weak self] data in
                guard let self = self else { return }
                
                self.centerAddr.accept(data)
            })
            .disposed(by: self.disposeBag)
        
        let feedList = self.feedListRawData
            .compactMap{ $0 }
        
        feedList
            .compactMap {
                $0.list
            }
            .bind(to: self.feedListData)
            .disposed(by: self.disposeBag)
        
        self.cLocation
            .compactMap { $0 }
            .bind(onNext: {[weak self] location in
                guard let self = self else { return }
                var param = [
                    "latlng" : "\(location.coordinate.latitude),\(location.coordinate.longitude)",
                    "key" : GMAP_KEY
                ]
                
                self.getAddrGeocode(param: param)

            })
            .disposed(by: self.disposeBag)
    }
    
    // 현재 위치 권한 검사
    func checkCurrentLocationAuth(_ completion: (() -> Void)? = nil) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.currentHandler = completion
            // Location services are enabled
            self.clManager = LocationManager.shared.clManager
            self.clManager?.delegate = self
            self.clManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.clManager?.requestAlwaysAuthorization()
            self.clManager?.startUpdatingLocation()
        } else {
            // Location services are not enabled
            self.isCheckCurrentLocationFail.accept(true)
        }
    }
}

// CLLocation 관련 Delegate
extension MapVMImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        
        manager.stopUpdatingLocation()
        
        UserManager.shared.currentLocation = CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        self.currentLocation.accept(UserManager.shared.currentLocation)
        
        if let handler = self.currentHandler {
            handler()
        }

    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        self.locationManagerStatus(status: manager.authorizationStatus)
    }
    
    
    @available(*, deprecated)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        self.locationManagerStatus(status: status)
    }
    
    private func locationManagerStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted:
            print("미정")
        case .denied:
            self.isCheckCurrentLocationFail.accept(true)
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            print("권한 있음")
            self.clManager?.startUpdatingLocation()
            self.isCheckCurrentLocationFail.accept(false)
        @unknown default:
            self.isCheckCurrentLocationFail.accept(true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error.accept(error)
    }
}
