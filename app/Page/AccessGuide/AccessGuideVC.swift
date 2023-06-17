//
//  AccessGuideVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit
import CoreLocation
import Photos

class AccessGuideVC: BaseVC {

    @IBOutlet weak var scrV: UIScrollView!
    @IBOutlet var contentV: UIView!
    
    @IBOutlet weak var completeBTN: UIButton!
    
    @IBOutlet weak var guideTitleLB: UILabel!
    @IBOutlet weak var guideSubLB: UILabel!
    
    @IBOutlet var checkLBList: [UILabel]!
    @IBOutlet var checkSubLBList: [UILabel]!
    
    private var clManager: CLLocationManager?

    convenience init() {
        self.init(nibName: "AccessGuide", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.organizeSubviews()
        self.settingsSubviews()
        self.bindUserEvents()
        self.bindOutputs()

    }
    
    private func organizeSubviews(){
        self.scrV.addSubview(self.contentV)
        self.contentV.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.width.equalTo(SCREEN_WIDTH)
            $0.height.equalToSuperview()
        }
    }
    
    private func settingsSubviews() {
        self.view.backgroundColor = .white
        
        
        self.scrV.do {
            $0.backgroundColor = .clear
            $0.keyboardDismissMode = .onDrag
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        self.contentV.do {
            $0.backgroundColor = .clear
        }
        
        self.completeBTN.do {
            $0.titleLabel?.text = "완료"
            $0.tintColor = .white
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 12
        }
        
        self.guideTitleLB.do {
            $0.font = .bold(size: 24)
            $0.textColor = .black
            $0.setLineHeight(spacing: 2.0)
        }
        
        self.guideSubLB.do {
            $0.font = .regular(size: 16)
            $0.setCharacterSpacing(kernValue: -0.16)
            $0.textColor = .init(r: 109, g: 113, b: 119)
        }
        
        self.checkLBList
            .compactMap { $0 }
            .forEach {
                $0.font = .regular(size: 18)
                $0.textColor = .black
                $0.setCharacterSpacing(kernValue: -0.18)
            }
        
        self.checkSubLBList
            .compactMap { $0 }
            .forEach {
                $0.font = .regular(size: 14)
                $0.setCharacterSpacing(kernValue: -0.14)
                $0.textColor = .init(r: 184, g: 189, b: 197)
            }
        
        self.clManager = LocationManager.shared.clManager
        self.clManager?.delegate = self
        self.clManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func bindUserEvents() {
        self.completeBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: { [weak self] in
                guard let self = self else{
                    return
                }
                DispatchQueue.main.async {
                    self.showLocationPermission(completion: { [weak self] in
                        
                        guard let self = self else{
                            return
                        }
                        self.showCameraPermission()
                    })
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindOutputs() {
        
    }

   
}

extension AccessGuideVC: CLLocationManagerDelegate {
    private func showCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                 if granted {
                     print("Camera: 권한 허용")
                 } else {
                     print("Camera: 권한 거부")
                 }
                self.showPhotoPermission(completion: { [weak self] in
                    
                    guard let self = self else{
                        return
                    }
                    self.movePage()
                    
                })
             })
    }
    
    
    private func showLocationPermission( completion: (() -> Void)? = nil ) {
        guard CLLocationManager.locationServicesEnabled() == true else{
            completion?()
            return
        }
        
        self.clManager?.requestAlwaysAuthorization()
    }
    
    private func showPhotoPermission( completion: (() -> Void)? = nil) {
        
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                completion?()
            }
        } else {
            PHPhotoLibrary.requestAuthorization { _ in
                completion?()
            }
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            print("권한 있음")
            self.clManager?.startUpdatingLocation()
            self.showCameraPermission()
        default:
            self.showCameraPermission()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        
        switch status {
        case .notDetermined:
            break
            
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            print("권한 있음")
            self.clManager?.startUpdatingLocation()
            self.showCameraPermission()
        default:
            self.showCameraPermission()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else {
            return
        }
        
        print("위도 \(location.coordinate.latitude),경도 \(location.coordinate.longitude)")
        
        UserManager.shared.currentLocation = CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        self.clManager?.stopUpdatingLocation()
    }
    
    private func movePage(){
        
        DispatchQueue.main.sync {
            self.dismiss(animated: true, completion: {
                UDF.set(true, forKey: "firstLaunch")
                NaviManager.shared.resetNavi {
                    CommonNav.moveLoginVC()
                }
            })
        }
    }
}
