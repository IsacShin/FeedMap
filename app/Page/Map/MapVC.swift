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
import Kingfisher
import GoogleMaps

class MapVC: BaseVC {

    @IBOutlet weak var gMapV: UIView!
    @IBOutlet weak var searchBTN: UIButton!
    
    @IBOutlet weak var currentSearchV: UIView!
    @IBOutlet weak var currentSearchLB: UILabel!
    @IBOutlet weak var currentSearchBTN: UIButton!
    @IBOutlet weak var currentSearchICO: UIImageView!
    
    @IBOutlet weak var selectTabV: UIView!
    @IBOutlet var selectTabLBS: [UILabel]!
    
    @IBOutlet weak var selectTabDateLB: UILabel!
    @IBOutlet weak var selectTabAddrLB: UILabel!
    @IBOutlet weak var selectTabTitleLB: UILabel!
    @IBOutlet weak var selectTabImgV: UIImageView!
    @IBOutlet weak var selectTabCmtLB: UILabel!
    
    @IBOutlet weak var selectImgVBTN: UIButton!
    
    var gMap: GMSMapView!
    weak var gMapViewDelegate: GMSMapViewDelegate?
//    var clusterManager: GMUClusterManager!
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
//        self.setClusterManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initializeData()
    }
    
    private var isFirst = true
    private func initializeData(){
        
//        guard self.isFirst == true else {
//            return
//        }
//        self.isFirst = false
        guard let token = UDF.string(forKey: "idToken") else {
            return
        }
        
        self.selectTabV.isHidden = true
        self.gMap.clear()
        
        CommonLoading.shared.show()
        self.vm.input.initializeData {
            self.vm.output.getFeedList(false, loca: nil) {
                CommonLoading.shared.hide()
            }
        }
    }
    
//    private func setClusterManager() {
//        let iconGenerator = MapClusterIconGenerator() // ⭐️
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        let renderer = GMUDefaultClusterRenderer(mapView: self.gMap, clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: self.gMap, algorithm: algorithm, renderer: renderer)
//        clusterManager.setMapDelegate(self)
//    }
    
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
        
        self.selectTabV.do {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
            $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            $0.backgroundColor = .clear
            $0.isHidden = true
        }
        
        self.selectTabLBS
            .compactMap { $0 }
            .forEach {
                $0.font = .regular(size: 15)
                $0.textColor = .white
            }
        
        self.selectTabDateLB.do {
            $0.font = .regular(size: 12)
        }
        
        self.selectTabTitleLB.do {
            $0.font = .bold(size: 17)
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
                CommonAdManager.shared.loadFullAd(parentVC: self)
                
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
                CommonAdManager.shared.loadFullAd(parentVC: self)
                self.vm.output.getFeedList(true, loca: self.cLocation) {
                    let check = self.vm.output.feedCheck.value

                    if check == false {
                        CommonAlert.showAlertType(vc: self, message: "이 장소에 이미 등록한 피드가 있습니다.", nil)
                    } else {
                        self.vm.input.cLocation.accept(self.cLocation)

                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.selectImgVBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                let data = self.vm.input.selectData.value
                var seed = FeedWriteSeedInfo()
                seed.address = data?.addr
                guard let lat = data?.latitude,
                      let lng = data?.longitude,
                      let dLat = Double(lat),
                      let dLng = Double(lng) else { return }
                
                let loca = CLLocation(latitude: dLat, longitude: dLng)
                seed.location = loca
                seed.pageType = .update

                CommonNav.moveFeedWriteVC(seed: seed)
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
                        CommonLoading.shared.hide()
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
        
        output.moveLocation
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] loca in
                guard let self = self else { return }
                self.mapCameraMove(location: loca)
                self.vm.output.getFeedList(true, loca: loca, completion: {
                    let check = self.vm.output.feedCheck.value
                    if check == false {
                        CommonAlert.showAlertType(vc: self, message: "이 장소에 이미 등록한 피드가 있습니다.", nil)
                    } else {
                        CommonAlert.showConfirmType(vc: self, message: "이 장소에 등록된 피드가 없습니다.\n피드를 등록해주세요" ,cancelTitle: "확인", completeTitle: "취소", {
                            var seed = FeedWriteSeedInfo()
                            seed.address = output.centerAddr.value
                            seed.location = loca
                            CommonNav.moveFeedWriteVC(seed: seed)
                        }, nil)
                    }
                })
            })
            .disposed(by: self.disposeBag)
        
        output.centerAddr
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] addr in
                print(addr)
            })
            .disposed(by: self.disposeBag)
        
        output.feedListData
            .asDriver()
            .compactMap {
                $0
            }
            .drive(onNext: {[weak self] list in
                list.forEach { data in
                    guard let lat = data.latitude,
                          let lng = data.longitude,
                          let dLat = Double(lat),
                          let dLng = Double(lng) else { return }
                    
                    let loca = CLLocation(latitude: dLat, longitude: dLng)
//                    self?.clusterManager.clearItems()
                    self?.createMarker(loca: loca, data: data)
//                    self?.clusterManager.cluster()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func createMarker(loca: CLLocation, data: FeedRawData) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: loca.coordinate.latitude, longitude: loca.coordinate.longitude)
        marker.title = data.addr
        marker.snippet = data.title
        
        marker.userData = data
        if let img = data.img1,
           let url = URL(string: img) {
            let v = UIView()
            v.frame = .init(x: 0, y: 0, width: 45, height: 45)
            v.layer.cornerRadius = v.frame.width / 2
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 2
            v.clipsToBounds = true
            let imgV = UIImageView()
            v.addSubview(imgV)
            imgV.snp.makeConstraints {
                $0.leading.trailing.top.bottom.equalToSuperview()
            }
            imgV.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    marker.iconView = v
                
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
        marker.map = self.gMap
//        self.clusterManager.add(marker)
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
//        mapView.selectedMarker = marker
        print("마커 클릭 ")
        if let data = marker.userData as? FeedRawData {
            self.vm.input.selectData.accept(data)
            if let img = data.img1,
               let url = URL(string: img) {
                self.selectTabImgV.kf.setImage(with: url)
            }
            self.selectTabCmtLB.text = data.comment
            self.selectTabAddrLB.text = data.addr
            self.selectTabTitleLB.text = data.title
            self.selectTabDateLB.text = data.date?.wddSimpleDateForm()
            self.selectTabV.isHidden = false
        }
        return true
    }
    
    // 지도 클릭 시
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("지도 클릭 ")
        self.selectTabV.isHidden = true
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
