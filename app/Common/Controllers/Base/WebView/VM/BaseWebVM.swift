//
//  BaseWebVM.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import RxSwift
import RxCocoa

class BaseWebVM {
    var urlStr: PublishRelay<String?>
    var completion: (()->Void?)?
    
    init() {
        urlStr = PublishRelay<String?>()
    }
}
