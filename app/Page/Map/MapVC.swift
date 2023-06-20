//
//  MapVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import GoogleMaps
import GooglePlaces

class MapVC: BaseVC {
    
    
    @IBOutlet weak var gMapV: UIView!
    @IBOutlet weak var searchBTN: UIButton!
    
    @IBOutlet weak var currentSearchV: UIView!
    @IBOutlet weak var currentSearchLB: UILabel!
    @IBOutlet weak var currentSearchBTN: UIButton!
    @IBOutlet weak var currentSearchICO: UIImageView!
    
    var gMap: GMSMapView!
    weak var gMapViewDelegate: GMSMapViewDelegate?
    var zoomLevel: Float = 15
    var cLocation: CLLocation?
    
    private var vm: MapVM!
    convenience init(vm: MapVM?) {
        self.init(nibName: "Map", bundle: nil)

        guard let vm = vm else { return }
        self.vm = vm
        
    }
    
    deinit {
        if self.gMap != nil {
            self.gMap.removeFromSuperview()
            self.gMap.delegate = nil
            self.gMap = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingSubviews()
        self.bindUI()
        self.bindUserEvents()
        self.bindOutputs()
        self.makeMapV()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initializeData()
    }
    
    private var isFirst = true
    private func initializeData(){
        
        guard self.isFirst == true else {
            return
        }
        self.isFirst = false
        
        CommonLoading.shared.show()
        self.vm.input.initializeData {
            CommonLoading.shared.hide()
        }
        
    }
    
    
    private func makeMapV() {
        self.gMap = GMSMapView()
        
        self.gMap.do {
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
            $0.isMyLocationEnabled = true
            $0.settings.myLocationButton = true
            $0.setMinZoom(5.0, maxZoom: 20.0)
            $0.mapType = .normal
            self.gMapViewDelegate = self
            $0.delegate = self.gMapViewDelegate
        }
        
        self.gMapV.addSubview(self.gMap)
        self.gMap.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalTo(self.gMapV)
        }
        
    }
    
    private func settingSubviews() {
        self.currentSearchV.do {
            $0.roundCorners(cornerRadius: 16, byRoundingCorners: .allCorners)
        }
        
        self.currentSearchLB.do {
            $0.font = .regular(size: 14)
            $0.setCharacterSpacing(kernValue: -0.98)
        }
        
        self.currentSearchICO.do {
            $0.image = UIImage(named: "cRefres")?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = .black
        }
    }
    
    private func bindUI() {
        
    }
    
    private func bindUserEvents() {
        self.searchBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                let urlStr = "https://isacshin.github.io/daumSearch/"
                CommonNav.moveBaseWebVC(requestUrl: urlStr)
            })
            .disposed(by: self.disposeBag)
        
        self.currentSearchBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                print("\(self.cLocation)")
            })
            .disposed(by: self.disposeBag)
        
    }
    
    private func bindOutputs() {
        let output = self.vm.output
        // 에러 처리
        output
            .error
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] err in
                guard let self = self else { return }
                CommonAlert.showAlertType(vc: self, message: err.localizedDescription, nil)
            })
            .disposed(by: self.disposeBag)
        
        // 현재 위치 권한 요청 실패
        output
            .isCheckCurrentLocationFail
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: { [weak self] isFail in
                guard let self = self else { return }
                
                if isFail == true {
                    
                    CommonAlert.showConfirmType(vc: self, message: "현재 위치를 찾을 수 없습니다.\n앱 설정으로 가서 위치서비스를 허용하시겠어요?", nil, {
                        guard let uUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        UIApplication.shared.open(uUrl)
                    })
                }
                
            })
            .disposed(by: self.disposeBag)
        
        output.currentLocation
            .asDriver()
            .compactMap { $0 }
            .drive(onNext: {[weak self] currentLoca in
                guard let self = self else { return }
                self.mapCameraMove(location: currentLoca)
            })
            .disposed(by: self.disposeBag)
    }

}

extension MapVC {
    private func mapCameraMove(location: CLLocation) {
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: self.zoomLevel
        )
        self.gMap.camera = camera
    }
}

extension MapVC: GMSMapViewDelegate {
    // 마커 클릭 시
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("마커 클릭 ")
        return true
    }
    
    // 지도 클릭 시
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("지도 클릭 ")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoomLevel = mapView.camera.zoom
        self.zoomLevel = zoomLevel
    }
    
    // 지도 중앙 위치
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let clocation: CLLocation = CLLocation(
            latitude: position.target.latitude,
            longitude: position.target.longitude
        )
        
        self.cLocation = clocation
        
    }
    
}
