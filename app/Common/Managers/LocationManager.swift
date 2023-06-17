//
//  LocationManager.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    var clManager = CLLocationManager()
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    deinit {
        self.clManager.stopUpdatingLocation()
    }
    
    func reqCurrentLocation() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse, .authorized:
                    self.clManager.startUpdatingLocation()
                default:
                    UserManager.shared.currentLocation = CLLocation(
                        latitude: 37.476284,
                        longitude: 127.03532
                    )
                }
            } else {
                UserManager.shared.currentLocation = CLLocation(
                    latitude: 37.476284,
                    longitude: 127.03532
                )
            }
        }
        
    }
}

extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else {
            UserManager.shared.currentLocation = CLLocation(
                latitude: 37.476284,
                longitude: 127.03532
            )
            return
        }
        
        print("위도 \(location.coordinate.latitude),경도 \(location.coordinate.longitude)")
        
        UserManager.shared.currentLocation = CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        self.clManager.stopUpdatingLocation()
    }
}
