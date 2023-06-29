//
//  FeedVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Kingfisher
import DropDown

class FeedVC: BaseVC {
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var morIMG: UIImageView!
    @IBOutlet weak var moreBTN: UIButton!
    
    @IBOutlet weak var tblV: UITableView!
    
    @IBOutlet var emptyV: UIView!
    
    @IBOutlet weak var adsV: UIView!
    
    let refresher = UIRefreshControl()
    
    private var dropDown = DropDown()
    private var vm: FeedVM!
    convenience init(vm: FeedVM?) {
        self.init(nibName: "Feed", bundle: nil)
        guard let vm = vm else { return }
        self.vm = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.organizeSubviews()
        self.settingSubviews()
        self.bindUI()
        self.bindUserEvents()
        self.bindOutputs()
    }
    
    private func organizeSubviews() {
        self.tblV.addSubview(self.emptyV)
        self.emptyV.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func settingSubviews() {
        self.view.backgroundColor = DARK_COLOR
        
        self.adsV.do {
            CommonAdManager.shared.addBanner(parentVC: self, subV: $0)
        }
        
        self.titleLB.do {
            $0.font = .bold(size: 20)
            $0.textColor = .white
        }
        
        self.morIMG.do {
            let img = UIImage(named: "more (1)")?.withRenderingMode(.alwaysTemplate)
            $0.image = img
            $0.tintColor = .white
        }
        
        self.dropDown.do {
            $0.anchorView = self.moreBTN
            $0.bottomOffset = CGPoint(x: 0, y:($0.anchorView?.plainView.bounds.height)!)
            $0.textColor = .white
            $0.backgroundColor = .lightGray
            $0.dataSource = ["전체 피드","내 피드"]
        }
        
        self.tblV.do{
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            
            $0.separatorStyle = .none
            $0.refreshControl = self.refresher
            
            $0.register(.init(nibName: "FeedTableVCell", bundle: nil),
                        forCellReuseIdentifier: FeedTableVCell.description())
            
            $0.rx.setDelegate(self).disposed(by: self.disposeBag)
            $0.backgroundColor = DARK_COLOR
            $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
        }
        
        self.emptyV.do {
            $0.backgroundColor = DARK_COLOR
        }
        
        self.refresher.do {
            $0.tintColor = .white
        }
    }
    
    private func bindUI() {
        self.refresher
            .rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: {[weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self?.vm.output.getFeedList(memId: nil) {
                        self?.refresher.endRefreshing()
                    }
                })
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindUserEvents() {
        
        self.moreBTN
            .rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                self.dropDown.show()
            })
            .disposed(by: self.disposeBag)
        
        self.dropDown.do {
            $0.selectionAction = { [weak self] (index: Int, item: String) in
                self?.dropDown.clearSelection()
                if index == 0 {
                    CommonLoading.shared.show()
                    self?.vm.output.getFeedList(memId: nil) {
                        CommonLoading.shared.hide()
                    }
                } else {
                    guard let memid = UDF.string(forKey: "memId") else { return }
                    CommonLoading.shared.show()
                    self?.vm.output.getFeedList(memId: memid) {
                        CommonLoading.shared.hide()
                    }
                }
            }
        }
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
       
        CommonLoading.shared.show()
        self.vm.output.getFeedList(memId: nil) {
            CommonLoading.shared.hide()
        }
        
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
        
        output
            .feedListData
            .asDriver()
            .map { list -> Bool in
                
                var result = true
                if list?.count == 0 {
                    result = false
                }
                return result
            }
            .drive(self.emptyV.rx.isHidden)
            .disposed(by: self.disposeBag)
            
        
        output
            .feedListData
            .asDriver()
            .compactMap {
                $0
            }
            .drive(self.tblV.rx.items(cellIdentifier: FeedTableVCell.description(), cellType: FeedTableVCell.self)) { [weak self] index, cellData, cell in
                
                guard let self = self else {
                    return
                }
               
                cell.selectionStyle = .none
                cell.mapCellData(pCellData: cellData)
                cell.mapVM(vm: self.vm)
                cell.tblV = self.tblV
                
            }
            .disposed(by: self.disposeBag)
    }
    
}

extension FeedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FeedTableVCell else { return }
        if indexPath.row == (self.vm.output.feedListData.value?.count ?? 0) - 1 {
            cell.lineV.isHidden = true
        } else {
            cell.lineV.isHidden = false
        }
    }
}
