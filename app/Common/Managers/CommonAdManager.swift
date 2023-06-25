//
//  CommonAdManager.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import UIKit
import GoogleMobileAds

// MARK: - ADMOB 관련
let BANNER_ADMOBKEY             = "ca-app-pub-6912457818283583/8311416199"
let FULL_SCREEN_ADMOBKEY        = "ca-app-pub-6912457818283583/7268182863"

let TEST_BANNER_ADMOBKEY        = "ca-app-pub-3940256099942544/2934735716"
let TEST_FULL_ADMOBKEY          = "ca-app-pub-3940256099942544/4411468910"

final class CommonAdManager: NSObject {
    
    static let shared = CommonAdManager()
    private var bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?
    
    public func addBanner(parentVC: BaseVC, subV: UIView) {
        self.bannerView = GADBannerView(adSize: GADAdSizeBanner)
        self.bannerView.do {
            $0.adUnitID = BANNER_ADMOBKEY
            $0.rootViewController = parentVC

            subV.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.trailing.leading.bottom.equalToSuperview()
            }
        }
        self.bannerView.load(GADRequest())
    }
    
    public func loadFullAd(parentVC: BaseVC) {
        DispatchQueue.main.async {
            GADInterstitialAd.load(withAdUnitID: FULL_SCREEN_ADMOBKEY, request: GADRequest()) { ad, error in
                if error != nil { return }
                if let ad = ad {
                    self.interstitial = ad
                    self.interstitial?.fullScreenContentDelegate = parentVC
                    
                    if self.interstitial != nil {
                        self.interstitial?.present(fromRootViewController: parentVC)
                    } else {
                        print("Ad wasn't ready")
                    }
                }
            }
        }
    }
    
}
