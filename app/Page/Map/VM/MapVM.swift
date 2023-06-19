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
}

protocol MapVMOutput {
    var error: BehaviorRelay<Error?> { get }
    var currentLocation: BehaviorRelay<CLLocation?> { get }
    var isCheckCurrentLocationFail: BehaviorRelay<Bool?> { get }

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
    
    private var clManager: CLLocationManager?
    private var currentHandler: (() -> Void)?
    
    override init() {
        super.init()
        self.bindParsing()
    }
    
    func initializeData(completion: @escaping () -> Void) {
        self.checkCurrentLocationAuth(completion)
    }
    
    private func bindParsing() {
        
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
