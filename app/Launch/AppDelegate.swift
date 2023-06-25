//
//  AppDelegate.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import UIKit
import AppTrackingTransparency
import AdSupport
import FirebaseCore
import GoogleMobileAds
import GoogleMaps
import GooglePlaces
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationVC:BaseNaviVC?
    
    var idfa: UUID {
        return ASIdentifierManager.shared().advertisingIdentifier
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
//        GADMobileAds.sharedInstance()
//            .requestConfiguration
//            .testDeviceIdentifiers = [
//                "2077ef9a63d2b398840261c8221a0c9b"
//            ]
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GMSServices.provideAPIKey(GMAP_KEY)
        GMSPlacesClient.provideAPIKey(GMAP_KEY)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("디바이스 토큰값 : "+deviceTokenString)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    // Active 상태일때
    func applicationDidBecomeActive(_ application: UIApplication) {
        if application.applicationState == .active {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    switch status {
                    case .authorized:
                        print("광고추적 허용")
                        print("IDFA: ", self.idfa)
                    case .denied, .notDetermined, .restricted:
                        print("광고추적 비허용")
                        print("IDFA: ", self.idfa)
                    @unknown default:
                        print("UNKNOWN")
                        print("IDFA: ", self.idfa)
                    }
                }
            } else {
                print("Under 14.0")
            }
        }
    }

}

