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
    
    var gMap: GMSMapView!
    weak var gMapViewDelegate: GMSMapViewDelegate?
    
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
            
            self.gMapViewDelegate = self
            $0.delegate = self.gMapViewDelegate
        }
        
        self.gMap.setMinZoom(1.0, maxZoom: 10.0)
        self.gMapV.addSubview(self.gMap)
        self.gMap.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalTo(self.gMapV)
        }
        
    }
    
    private func settingSubviews() {
        
    }
    
    private func bindUI() {
        
    }
    
    private func bindUserEvents() {
        
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
                
            })
            .disposed(by: self.disposeBag)
    }

}

extension MapVC: GMSMapViewDelegate {
    
}
